#!/bin/bash -x
# 0 21 * * * sleep $((RANDOM%3600)) && /opt/blocklist/blocklist.sh
# https://sysadmin.info.pl/en/blog/using-blocklist-with-iptables-and-firewalld/
IP_BLOCKLIST=/etc/ip-blocklist.conf
IP_BLOCKLIST_TMP=/tmp/ip-blocklist.tmp
IP_BLOCKLIST_CUSTOM=/etc/ip-blocklist-custom.conf # optional
TIME_RESOLUTION=3600
NOW=$(($(date +%s) / TIME_RESOLUTION))

renice -n 9 -p $$
ionice -c 3 -p $$

curl_with_cache() {
  local url=$1
  cache_file=/opt/blocklist/${1//'/'/'#'}
  local cache_time=${2:-7}
  ((cache_time *= (86400 / TIME_RESOLUTION) ))
  local cache_modified=0

  if [[ -f $cache_file ]]; then
    cache_modified=$(($(stat -c %Y "$cache_file") / TIME_RESOLUTION))
  fi

  if (( (NOW - cache_modified) > cache_time )); then
    curl --connect-timeout 10 "$url" >"$cache_file"
  fi
}

add_rule() {
  zgrep -Po '(^|(?<![0-9]))(?:\d{1,3}\.){3}\d{1,3}(?:/\d{1,2})?((?=[^0-9])|$)' "$1" >>$IP_BLOCKLIST_TMP
  zgrep -Po '^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))((?=\s)|$)' "$1" >>${IP_BLOCKLIST_TMP}.6
}

# rule
r() {
  local cache_file
  curl_with_cache "$1" "$2"
  add_rule "$cache_file"
}

add_rule "$IP_BLOCKLIST_CUSTOM"

r "http://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1"           # Project Honey Pot Directory of Dictionary Attacker IPs
r "http://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.1.1.1"  # TOR Exit Nodes (ipsum)
# "http://www.maxmind.com/en/anonymous_proxies" 30                     # MaxMind GeoIP Anonymous Proxies
# "https://www.maxmind.com/en/high-risk-ip-sample-list" 30             # MaxMind High Risk Sample List
r "http://danger.rulez.sk/projects/bruteforceblocker/blist.php"        # BruteForceBlocker IP List
# "https://rules.emergingthreats.net/blockrules/compromised-ips.txt"   # Emerging Threats - Russian Business Networks List
# "http://www.spamhaus.org/drop/drop.lasso"                            # Spamhaus Don't Route Or Peer List (DROP)
r "http://cinsscore.com/list/ci-badguys.txt"                           # C.I. Army Malicious IP List
# "http://www.autoshun.org/files/shunlist.csv"                         # Autoshun Shun List
r "http://lists.blocklist.de/lists/all.txt" 1                          # blocklist.de fail2ban reporting service
r "https://fx.vc-mp.eu/shared/iplist.txt"                              # ferex badlist
r "https://feodotracker.abuse.ch/downloads/ipblocklist_aggressive.txt" # FEODO tracker
r "https://reputation.alienvault.com/reputation.generic"               # ALIENVAULT REPUTATION
r "http://www.darklist.de/raw.php"                                     # DARKLIST DE
# "http://osint.bambenekconsulting.com/feeds/c2-dommasterlist-high.txt" 1
# "http://osint.bambenekconsulting.com/feeds/c2-dommasterlist.txt" 1
r "http://osint.bambenekconsulting.com/feeds/c2-ipmasterlist-high.txt" 1
r "http://osint.bambenekconsulting.com/feeds/c2-ipmasterlist.txt" 1
# "http://osint.bambenekconsulting.com/feeds/c2-masterlist.txt" 1
# "http://osint.bambenekconsulting.com/feeds/dga-feed.txt" 1
r "https://www.binarydefense.com/banlist.txt"                            # Binary Defense Systems
r "https://raw.githubusercontent.com/stamparm/ipsum/master/levels/2.txt" # https://github.com/stamparm/ipsum
r "http://sblam.com/blacklist.txt"                                       # SBLAM
r "http://blocklist.greensnow.co/greensnow.txt"
r "http://charles.the-haleys.org/ssh_dico_attack_hdeny_format.php/hostsdeny.txt"
# "https://www.malwaredomainlist.com/hostslist/ip.txt"
r "https://www.stopforumspam.com/downloads/toxic_ip_cidr.txt"
# 'http://list.iblocklist.com/?list=erqajhwrxiuvjxqrrwfj&fileformat=p2p&archiveformat=gz'

#Consolidate the shodan.io IP addresses database
#cat /opt/blocklist/shodan.txt >> $IP_BLOCKLIST_TMP

#Sort the list
cidr-merger <$IP_BLOCKLIST_TMP >$IP_BLOCKLIST
cidr-merger <$IP_BLOCKLIST_TMP.6 >$IP_BLOCKLIST.6

#Remove temporary list
rm $IP_BLOCKLIST_TMP
rm $IP_BLOCKLIST_TMP.6

BLSIZE=$(wc -l $IP_BLOCKLIST | cut -d' ' -f1)
BLSIZE6=$(wc -l $IP_BLOCKLIST.6 | cut -d' ' -f1)
echo "Blocklist size: $BLSIZE, $BLSIZE6"
nextpow2() {
  local -n __x=$1
   ((
    __x--,
    __x |= __x >> 1,
    __x |= __x >> 2,
    __x |= __x >> 4,
    __x |= __x >> 8,
    __x |= __x >> 16,
    __x |= __x >> 32,
    __x++
  ))
}
((
  BLSIZE = BLSIZE * 4 / 3,
  BLSIZE6 = BLSIZE6 * 4 / 3
))
nextpow2 BLSIZE
nextpow2 BLSIZE6

set +x
# https://serverfault.com/a/1046246
mkdir -p /etc/nftables/idempotent
# Generate nftables.
nft flush ruleset
{
  cat <<EOF
add table ip bl
add set ip bl blocklist { type ipv4_addr; size $BLSIZE; flags interval; }
flush set bl blocklist
EOF
  while IFS= read -r line; do
    printf 'add element ip bl blocklist { %s }\n' "$line"
  done </etc/ip-blocklist.conf
  cat <<EOF
add chain ip bl input { type filter hook input priority 0; }
add chain ip bl forward { type filter hook forward priority 0; }
add rule ip bl input ip saddr @blocklist drop
add rule ip bl forward ip saddr @blocklist drop
EOF
} > /etc/nftables/idempotent/ip-blocklist.nft

{
  cat <<EOF
add table ip6 bl6
add set ip6 bl6 blocklist6 { type ipv6_addr; size $((BLSIZE6 * 2)); flags interval; }
flush set ip6 bl6 blocklist6
EOF
  while IFS= read -r line; do
    printf 'add element ip6 bl6 blocklist6 { %s }\n' "$line"
  done </etc/ip-blocklist.conf.6
  cat <<EOF
add chain ip6 bl6 input { type filter hook input priority 0; }
add chain ip6 bl6 forward { type filter hook forward priority 0; }
add rule ip6 bl6 input ip6 saddr @blocklist6 drop
add rule ip6 bl6 forward ip6 saddr @blocklist6 drop
EOF
} > /etc/nftables/idempotent/ip-blocklist6.nft

# Reload nftables.
nft -o -f /etc/nftables/idempotent/ip-blocklist.nft
nft -o -f /etc/nftables/idempotent/ip-blocklist6.nft
