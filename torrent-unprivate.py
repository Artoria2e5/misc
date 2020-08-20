#!/usr/bin/env python3
"""
Make a given torrent file non-private.

Do not upload with the same IP as your PT client.

```bash
./torrent-unprivate.py *.torrent
mv *.pub *.pub.torrent my-public-cave/
```
"""
import sys
import os
from torrentool.api import Torrent
from typing import Optional

# https://github.com/ngosang/trackerslist/blob/master/trackers_best_ip.txt
ANNOUNCE_LIST = [x for x in """
udp://31.14.40.30:6969/announce

udp://93.158.213.92:1337/announce

udp://188.241.58.209:6969/announce

udp://163.172.217.67:1337/announce

udp://151.80.120.115:2710/announce

udp://151.80.120.112:2710/announce

udp://208.83.20.20:6969/announce

udp://194.182.165.153:6969/announce

udp://5.206.38.65:6969/announce

udp://37.235.174.46:2710/announce

udp://185.181.60.67:80/announce

udp://89.234.156.205:451/announce

udp://185.244.173.140:6969/announce

udp://176.113.71.60:6961/announce

udp://51.15.40.114:80/announce

udp://207.241.231.226:6969/announce

udp://207.241.226.111:6969/announce

udp://212.47.227.58:6969/announce
""".split('\n') if x]


def unpriv(path: str, link: Optional[bool] = None) -> None:
    t = Torrent.from_file(path)
    t.private = False
    d, _ = os.path.splitext(path)
    fp = d + ".pub.torrent"
    t.announce_urls = ANNOUNCE_LIST
    t.to_file(fp)
    print("{}\t{}".format(t.magnet_link, fp))

    if os.path.isdir(d) and link is not False:
        bd = os.path.basename(d)
        try:
            os.symlink(bd, bd + ".pub")
        except BaseException as e:
            if link is True:
                raise


if __name__ == '__main__':
    for f in sys.argv[1:]:
        unpriv(f)
