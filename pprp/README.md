pPRP
====

Code for [Gerbicz pPRP test of Mp/d](https://www.mersenneforum.org/showthread.php?t=23462) given p, res2048 = `pow(3, mp-1, mp) % (1 << 2048)`, and d.
In actuality res2048 is calculated from `pow(3, mp+1, mp) * pow(3, -2, mp)` because mp+1 has very few 1 bits.

The issue is that we need to get `pow(3, mp, mp) % (1 << t)` out of res2048 for a t as large as possible. This code does that with `t = 2046`. There is a "remainder"
component being lost by the division to get `pow(3, mp-1, mp)`, but apparently brute-forcing `{0, 1, 2}` still works to provide a useful pPRP test.

I am yet to find a counterexample where the original pPRP test fails but this one passes (or vice versa), but I have not done an exhaustive search.

~~Being written in Python 3's native bigint, this code is not exactly fast for large p and d.~~ It now uses gmpy2.
