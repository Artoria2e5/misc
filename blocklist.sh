#!/bin/bash -x
# 0 21 * * * sleep $((RANDOM%3600)) && /opt/blocklist/blocklist.sh
IP_BLOCKLIST=/etc/ip-blocklist.conf
IP_BLOCKLIST_TMP=/tmp/ip-blocklist.tmp
IP_BLOCKLIST_CUSTOM=/etc/ip-blocklist-custom.conf # optional
NOW=$(($(date +%s) / 86400))

renice -n 9 -p $$
ionice -c 3 -p $$

curl_with_cache() {
  local url=$1
  cache_file=/opt/blocklist/${1//'/'/'#'}
  local cache_time=${2:7}
  local cache_modified=0

  if [[ -f $cache_file ]]; then
    cache_modified=$(($(stat -c %Y $cache_file) / 86400))
  fi

  if (( (NOW - cache_modified) > cache_time )); then
    curl --connect-timeout 10 "$url" >"$cache_file"
  fi
}

# rule
r() {
  curl_with_cache "$1" "$2"
  zgrep -Po '(^|(?<![0-9]))(?:\d{1,3}\.){3}\d{1,3}(?:/\d{1,2})?((?=[^0-9])|$)' "$cache_file" >>$IP_BLOCKLIST_TMP
  zgrep -Po '^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))((?=\s)|$)' "$cache_file" >>${IP_BLOCKLIST_TMP}.6
}

r "http://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1"           # Project Honey Pot Directory of Dictionary Attacker IPs
# "http://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.1.1.1"  # TOR Exit Nodes (ipsum)
# "http://www.maxmind.com/en/anonymous_proxies" 30                     # MaxMind GeoIP Anonymous Proxies
r "https://www.maxmind.com/en/high-risk-ip-sample-list" 30             # MaxMind High Risk Sample List
r "http://danger.rulez.sk/projects/bruteforceblocker/blist.php"        # BruteForceBlocker IP List
r "https://rules.emergingthreats.net/blockrules/compromised-ips.txt"   # Emerging Threats - Russian Business Networks List
r "http://www.spamhaus.org/drop/drop.lasso"                            # Spamhaus Don't Route Or Peer List (DROP)
r "http://cinsscore.com/list/ci-badguys.txt"                           # C.I. Army Malicious IP List
# "http://www.autoshun.org/files/shunlist.csv"                         # Autoshun Shun List
r "http://lists.blocklist.de/lists/all.txt" 1                          # blocklist.de fail2ban reporting service
r "https://fx.vc-mp.eu/shared/iplist.txt"                              # ferex badlist
r "https://feodotracker.abuse.ch/downloads/ipblocklist_aggressive.txt" # FEODO tracker
r "https://reputation.alienvault.com/reputation.generic"               # ALIENVAULT REPUTATION
r "http://www.darklist.de/raw.php"                                     # DARKLIST DE
r "http://osint.bambenekconsulting.com/feeds/c2-dommasterlist-high.txt" 1
r "http://osint.bambenekconsulting.com/feeds/c2-dommasterlist.txt" 1
r "http://osint.bambenekconsulting.com/feeds/c2-ipmasterlist-high.txt" 1
r "http://osint.bambenekconsulting.com/feeds/c2-ipmasterlist.txt" 1
r "http://osint.bambenekconsulting.com/feeds/c2-masterlist.txt" 1
r "http://osint.bambenekconsulting.com/feeds/dga-feed.txt" 1
r "https://www.binarydefense.com/banlist.txt"                         # Binary Defense Systems
r "https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt" # https://github.com/stamparm/ipsum
r "http://sblam.com/blacklist.txt"                                    # SBLAM
r "http://blocklist.greensnow.co/greensnow.txt"
r "http://charles.the-haleys.org/ssh_dico_attack_hdeny_format.php/hostsdeny.txt"
r "https://www.malwaredomainlist.com/hostslist/ip.txt"
r "https://www.stopforumspam.com/downloads/toxic_ip_cidr.txt"
r 'http://list.iblocklist.com/?list=erqajhwrxiuvjxqrrwfj&fileformat=p2p&archiveformat=gz'

#Consolidate the shodan.io IP addresses database
#cat /opt/blocklist/shodan.txt >> $IP_BLOCKLIST_TMP

#Sort the list
cidr-merger <$IP_BLOCKLIST_TMP >$IP_BLOCKLIST
cidr-merger <$IP_BLOCKLIST_TMP.6 >$IP_BLOCKLIST.6

#Remove temporary list
rm $IP_BLOCKLIST_TMP
rm $IP_BLOCKLIST_TMP.6

wc -l $IP_BLOCKLIST
wc -l $IP_BLOCKLIST.6

### Section for firewalld
firewall-cmd --delete-ipset=blocklist --permanent
firewall-cmd --permanent --new-ipset=blocklist --type=hash:net --option=family=inet --option=hashsize=1048576 --option=maxelem=1048576
firewall-cmd --permanent --ipset=blocklist --add-entries-from-file=/etc/ip-blocklist.conf
firewall-cmd --permanent --new-ipset=blocklist6 --type=hash:net --option=family=inet6 --option=hashsize=1048576 --option=maxelem=1048576
firewall-cmd --permanent --ipset=blocklist6 --add-entries-from-file=/etc/ip-blocklist.conf.6
firewall-cmd --reload
wc -l $IP_BLOCKLIST
wc -l $IP_BLOCKLIST.6
