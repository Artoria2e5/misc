#!/usr/bin/python3
# Example: python3 res2.py 2069 2081 2083 2087 2089 2099 2111 2113 2129
t = 2046

def res(p: int) -> None:
    mp = (1 << p) - 1
    res_p2 = pow(3, mp+1, mp)
    inv3 = pow(3, -1, mp)
    res_p1 = res_p2 * inv3 % mp
    res = res_p1 * inv3 % mp
    res2048 = res % (2**(t+2))

    # Difference from imposters:
    rem3 = ((res_p1 % (2**t)) - res2048 * 3) % (2**t)
    rem9 = ((res_p2 % (2**t)) - res2048 * 9) % (2**t)

    print(f"p: {p}")
    print(f"rem3: {rem3}, rem9: {rem9}")
    print(f"res2048: {hex(res2048)}")
    print()

import sys
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python res2.py <p>")
        sys.exit(1)
    for i in sys.argv[1:]:
        p = int(i)
        res(p)
