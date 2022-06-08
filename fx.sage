load("attack.sage")
load("helper_functions.sage")
load("rules.sage")


def fx_gms_search():
    N = 5
    ED = [random_permutation(2^N, inverseToo=True) for _ in range(2^N)]
    E, D = [ED[i][0] for i in range(2^N)], [ED[i][1] for i in range(2^N)]
    RND = random_permutation(2^N)

    key = [ZZ.random_element(2^N), ZZ.random_element(2^N), ZZ.random_element(2^N)]
    assert key[1] != 0, "key is zero"
    assert key[2] != 0, "key is zero"

    FX = lambda x,y: E[key[0]](x ^^ key[1]) ^^ key[2]
    ENC = lambda x, y: E[y](x)
    DEC = lambda x, y: D[y](x)
    XOR = lambda x,y: x^^y
    FX_rnd = lambda x,y: RND(x)

    U = [u for u in range(2^N) for _ in range(2^N)]
    X = [x for _ in range(2^N) for x in range(2^N)]

    C_init = [U, X]

    GATES = [XOR, FX, ENC]
    GATES_random = [XOR, FX_rnd, ENC]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_single_input([1]),
             gen_rule_number_of_oracles(MIN=[([1], 1)])]

    print(key)
    CI = CircuitIterator(C_init, GATES, 3, RULES, GATES_random)
    #CI.search_periodic_circuit_gms(N, N, u_=key[0], compare_random=True)
    CI.search_periodic_circuit_gms(N, N, compare_random=True)


