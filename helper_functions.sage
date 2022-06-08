import random

def random_permutation(N, inverseToo=False):
    """
    Return a random permutation P on {0, ..., N-1} and when 
    indicated its inverse.
    """
    p = Permutations(N).random_element()
    p_inv = p.inverse()
    p, p_inv = list(p), list(p_inv)
    def P(x): return p[x]-1
    def P_inv(x): return p_inv[x]-1
    return (P, P_inv) if inverseToo else P

def random_function(N, M):
    """
    Return a random function F: {0, ..., N-1} -> {0, ..., M-1}.
    """
    f = [ZZ.random_element(M) for _ in range(N)]
    def F(x): return f[x]
    return F

