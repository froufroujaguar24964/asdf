load("attack.sage")
load("helper_functions.sage")
load("rules.sage")

def soka_search_gms():
    # sample keys and random permutation
    N = 6
    key = random.sample(range(1, 2^N), 2)
    print("Key: ", key)
    P = random_permutation(2^N)

    # prepare gates
    P_ = lambda x,y: P(x)
    E = lambda x, y: P(P(x^^key[0]) ^^ key[1]) ^^ P(x^^key[0]) ^^ key[0] ^^ key[1]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P_]

    rnd = random_permutation(2^N)
    E_rnd = lambda x, y: rnd(x)
    GATES_rnd = [XOR, E_rnd, P_]


    # prepare input nodes
    U = [u for u in range(2^N) for _ in range(2^N)]
    X = [x for _ in range(2^N) for x in range(2^N)]

    C_init = [U, X]
    RULES = [rule_is_normal,
             gen_rule_single_input([1, 2]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 6, RULES, GATES_rnd)
    CI.search_periodic_circuit_gms(N, N, u_=key[1], compare_random=True)
    # => u*=key[1], s = key[0]


def soka_search():
    # sample keys and random permutation
    N = 6
    key = random.sample(range(1, 2^N), 2)
    print("Key: ", key)
    P = random_permutation(2^N)

    # prepare gates
    P_ = lambda x,y: P(x)
    E = lambda x, y: P(P(x^^key[0]) ^^ key[1]) ^^ P(x^^key[0]) ^^ key[0] ^^ key[1]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P_]

    rnd = random_permutation(2^N)
    E_rnd = lambda x, y: rnd(x)
    GATES_rnd = [XOR, E_rnd, P_]


    # prepare input nodes
    X = [x for x in range(2^N)]

    C_init = [X]
    RULES = [rule_is_normal,
             gen_rule_single_input([1, 2]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 8, RULES, GATES_rnd)
    CI.search_periodic_circuit(compare_random=True)
    # => nothing


def soka21_search():
    # sample keys and random permutation
    N = 6
    key = random.sample(range(1, 2^N), 1)[0]
    print("Key: ", key)
    P1 = random_permutation(2^N)
    P2 = random_permutation(2^N)

    # prepare gates
    P1_ = lambda x,y: P1(x)
    P2_ = lambda x,y: P2(x)
    E = lambda x, y: P2(P1(x ^^ key) ^^ key) ^^ P1(x^^key)^^key
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P1_, P2_]

    rnd = random_permutation(2^N)
    E_rnd = lambda x, y: rnd(x)
    GATES_rnd = [XOR, E_rnd, P1_, P2_]


    # prepare input nodes
    X = [x for x in range(2^N)]

    C_init = [X]
    RULES = [rule_is_normal,
             gen_rule_single_input([1, 2, 3]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 7, RULES, GATES_rnd)
    CI.search_periodic_circuit(compare_random=True)
    # => nothing

