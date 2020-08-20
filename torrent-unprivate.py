#!/usr/bin/env python3
"""
Make a given torrent file non-private.

./torrent-unprivate.py *.torrent
"""
import sys
import os
from torrentool.api import Torrent
from typing import Optional


def unpriv(path: str, link: Optional[bool]) -> None:
    if link is None:
        link = "try"

    t = Torrent.from_file(path)
    t.private = False
    d: str, _ = os.path.splitext(path)
    fp = d + ".pub.torrent"
    t.to_file(fp)
    print("{}\t{}".format(t.magnet_link, fp))

    if os.path.isdir(d) and link:
        bd = os.path.basename(d)
        try:
            os.symlink(bd, bd + ".pub")
        except e:
            if link is True:
                raise


if __name__ == '__main__':
    for f in sys.argv[1:]:
        unpriv(f)
