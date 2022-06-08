load("attack.sage")
load("rules.sage")
load("helper_functions.sage")


def duplex_sponge(F_R, F_C, init_r, init_c):
    # assuming r = c
    def ENC(A0, A1):
        state_r, state_c = init_r ^^ A0, init_c
        state_r, state_c = F_R(state_r, state_c), F_C(state_r, state_c)
        Z0 = state_r
        state_r, state_c = state_r ^^ A1, state_c
        state_r, state_c = F_R(state_r, state_c), F_C(state_r, state_c)
        Z1 = state_r
        return Z0, Z1
    return ENC

def sponge_search():
    N = 8
    init_r = 0
    init_c = ZZ.random_element(2^N) # key
    F, F_inv = random_permutation(2^(2*N), inverseToo=True)
    def F_(R, C): return F((R << N) + C)
    F_R = lambda a, b: F_(a, b) >> N
    F_C = lambda a, b: F_(a, b) % 2^N
    ENC = duplex_sponge(F_R, F_C, init_r, init_c)
    E_0 = lambda a, b: ENC(a, b)[0]
    E_1 = lambda a, b: ENC(a, b)[1]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E_0, E_1, F_R, F_C]

    ENC_random = random_permutation(2^(2*N))
    E_0_random = lambda a, b: ENC_random((a << N) + b) >> N
    E_1_random = lambda a, b: ENC_random((a << N) + b) % 2^N
    GATES_random = [XOR, E_0_random, E_1_random, F_R, F_C]

    def oracles(C):
        n = C.num_verts
        v = n-1
        l, r = C.left(v), C.right(v)
        # at least one oracle in complete circuit
        if n == C.k + C.q and sum(C.gates.count(g) for g in [1,2]) == 0: return False
        return True


    RULES = [rule_is_normal, rule_xors, oracles, gen_rule_inputs_to_output([0], [(1, 2)]),
             gen_rule_single_input([1])]

    X = [x for x in range(2^N) for _ in range(2)]
    a = [ZZ.random_element(2^N), ZZ.random_element(2^N)]
    assert a[0] != a[1], "constants equal"
    AB = [a[i] for _ in range(2^N) for i in range(2)]
    ANB = [a[1-i] for _ in range(2^N) for i in range(2)]
    C_init = [X]
    #C_init = [X, AB, ANB]

    CI = CircuitIterator(C_init, GATES, 5, RULES, GATES_random)
    print(init_r, init_c)
    print(a)
    CI.search_periodic_circuit(compare_random=True, progress=True)

