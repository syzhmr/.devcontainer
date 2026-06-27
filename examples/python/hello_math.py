from fractions import Fraction
from math import prod


def binomial(n: int, k: int) -> int:
    if k < 0 or k > n:
        return 0
    k = min(k, n - k)
    numerator = prod(range(n - k + 1, n + 1))
    denominator = prod(range(1, k + 1))
    return numerator // denominator


if __name__ == "__main__":
    print("sum_{k=0}^{5} binomial(5, k) =", sum(binomial(5, k) for k in range(6)))
    print("1/3 + 1/6 =", Fraction(1, 3) + Fraction(1, 6))
