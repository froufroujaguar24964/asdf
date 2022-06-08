load("attack.sage")
load("helper_functions.sage")
load("rules.sage")

def iterated_even_mansour_gms_search():
    N = 5
    key = [ZZ.random_element(2^N), ZZ.random_element(2^N), ZZ.random_element(2^N)]
    assert key[0] != 0, "key is zero"
    assert key[1] != 0, "key is zero"
    assert key[2] != 0, "key is zero"

    U = [u for u in range(2^N) for _ in range(2^N)]
    X = [x for _ in range(2^N) for x in range(2^N)]
    C_init = [U, X]

    P, P_inv = random_permutation(2^N, inverseToo=True)
    RP, RP_inv = random_permutation(2^N, inverseToo=True)
    P_ = lambda x,y: P(x)
    P_inv_ = lambda x,y: P_inv(x)
    RP_ = lambda x,y: RP(x)
    RP_inv_ = lambda x,y: RP_inv(x)

    E = lambda x, y: P(P(x ^^ key[0]) ^^ key[1]) ^^ key[2]
    D = lambda x, y: P_inv(P_inv(x ^^ key[2]) ^^ key[1]) ^^ key[0]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, D, P_, P_inv_]
    GATES_random = [XOR, RP_, RP_inv_, P_, P_inv_]

    RULES = [rule_is_normal, rule_xors, gen_rule_single_input([1,2,3,4]),
             gen_rule_number_of_oracles(MIN=[([1], 1)])]

    print(key)

    CI = CircuitIterator(C_init, GATES, 5, RULES, GATES_random)
    CI.search_periodic_circuit_gms(N, N, compare_random=True, progress=True)

def iterated_even_mansour2_gms_search():
    N = 5
    key = [ZZ.random_element(2^N), ZZ.random_element(2^N), ZZ.random_element(2^N)]
    assert key[0] != 0, "key is zero"
    assert key[1] != 0, "key is zero"
    assert key[2] != 0, "key is zero"

    U = [u for u in range(2^N) for _ in range(2^N)]
    X = [x for _ in range(2^N) for x in range(2^N)]
    C_init = [U, X]

    P, P_inv = random_permutation(2^N, inverseToo=True)
    P2, P2_inv = random_permutation(2^N, inverseToo=True)
    RP, RP_inv = random_permutation(2^N, inverseToo=True)
    P_ = lambda x,y: P(x)
    P_inv_ = lambda x,y: P_inv(x)
    P2_ = lambda x,y: P2(x)
    P2_inv_ = lambda x,y: P2_inv(x)
    RP_ = lambda x,y: RP(x)
    RP_inv_ = lambda x,y: RP_inv(x)

    E = lambda x, y: P2(P(x ^^ key[0]) ^^ key[1]) ^^ key[2]
    D = lambda x, y: P_inv(P2_inv(x ^^ key[2]) ^^ key[1]) ^^ key[0]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P_, P_inv_, P2_, P2_inv_]
    GATES_random = [XOR, RP_, P_, P_inv_, P2_, P2_inv_]

    RULES = [rule_is_normal, rule_xors, gen_rule_single_input([1,2,3, 4, 5]),
             gen_rule_number_of_oracles(MIN=[([1], 1)])]

    print(key)

    CI = CircuitIterator(C_init, GATES, 5, RULES, GATES_random)
    CI.search_periodic_circuit_gms(N, N, compare_random=True, progress=True)

def iterated_even_mansour3_gms_search():
    N = 4
    key = [ZZ.random_element(2^N), ZZ.random_element(2^N),
           ZZ.random_element(2^N), ZZ.random_element(2^N)]
    assert key[0] != 0, "key is zero"
    assert key[1] != 0, "key is zero"
    assert key[2] != 0, "key is zero"
    assert key[3] != 0, "key is zero"

    U = [u for u in range(2^N) for _ in range(2^N)]
    X = [x for _ in range(2^N) for x in range(2^N)]
    C_init = [U, X]

    P, P_inv = random_permutation(2^N, inverseToo=True)
    P_ = lambda x,y: P(x)
    P_inv_ = lambda x,y: P_inv(x)
    E = lambda x, y: P(P(P(x ^^ key[0])^^key[1])^^key[2])^^key[3]
    D = lambda x, y: P_inv(P_inv(P_inv(x ^^ key[0])^^key[1])^^key[2])^^key[3]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P_, P_inv_]

    RP, RP_inv = random_permutation(2^N, inverseToo=True)
    RP_ = lambda x,y: RP(x)
    RP_inv_ = lambda x,y: RP_inv(x)

    GATES_random = [XOR, RP_, P_, P_inv_]

    RULES = [rule_is_normal, rule_xors, gen_rule_single_input([1,2,3]),
             gen_rule_number_of_oracles(MIN=[([1], 1)])]

    print(key)

    CI = CircuitIterator(C_init, GATES, 5, RULES, GATES_random)
    CI.search_periodic_circuit_gms(N, N, compare_random=True)

