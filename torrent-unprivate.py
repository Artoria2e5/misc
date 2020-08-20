#!/usr/bin/env python3
"""
Make a given torrent file non-private.

```bash
./torrent-unprivate.py *.torrent
mv *.pub *.pub.torrent my-public-cave/
```
"""
import sys
import os
from torrentool.api import Torrent
from typing import Optional


def unpriv(path: str, link: Optional[bool] = None) -> None:
    t = Torrent.from_file(path)
    t.private = False
    d, _ = os.path.splitext(path)
    fp = d + ".pub.torrent"
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
