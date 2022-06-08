load("attack.sage")
load("helper_functions.sage")
load("rules.sage")

# Quantum attacks on Sum of Even-Mansour pseudorandom functions
# https://doi.org/10.1016/j.ipl.2021.106172

def soem1_search():
    # rediscover attack from theorem1
    # sample keys and random permutation
    N = 6
    key = random.sample(range(1, 2^N), 2)
    print("Key: ", key)
    P = random_permutation(2^N)

    # prepare gates
    P1 = lambda x,y: P(x)
    E = lambda x, y: P(x ^^ key[0]) ^^ key[0] ^^ P(x ^^ key[1]) ^^ key[1]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P1]

    rnd = random_permutation(2^N)
    E_rnd = lambda x, y: rnd(x)
    GATES_rnd = [XOR, E_rnd, P1]

    # prepare input nodes
    X = [x for x in range(2^N)]
    #Z = [E(0,0) for _ in range(2^N)]
    C_init = [X]

    RULES = [rule_is_normal,
             gen_rule_single_input([1, 2]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 1, RULES, GATES_rnd)
    CI.search_periodic_circuit()
    # => Period K = key[0] ^^ key[1]

    # second search with K as constant
    K = [key[0]^^key[1] for _ in range(2^N)]
    C_init = [X, K]
    CI = CircuitIterator(C_init, GATES, 6, RULES, GATES_rnd)
    CI.search_periodic_circuit(trivial_periods=[(K[0],), tuple(X[1:])])
    # => Period K, key[0] and key[1]

def soem21_search():
    # rediscover attack from theorem2
    # sample keys and random permutation
    N = 6
    key = random.sample(range(1, 2^N), 1)[0]
    print("Key: ", key)
    P = [random_permutation(2^N) for _ in range(2)]

    # prepare gates
    P1 = lambda x,y: P[0](x)
    P2 = lambda x,y: P[1](x)
    E = lambda x, y: P[0](x ^^ key) ^^ key ^^ P[1](x ^^ key)
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P1, P2]

    rnd = random_permutation(2^N)
    E_rnd = lambda x, y: rnd(x)
    GATES_rnd = [XOR, E_rnd, P1, P2]

    # prepare input nodes
    X = [x for x in range(2^N)]
    C_init = [X]

    RULES = [rule_is_normal,
             gen_rule_single_input([1, 2]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 5, RULES, GATES_rnd)
    CI.search_periodic_circuit()
    # => Period key[0]

def soem22_gms_search():
    # rediscover attack from theorem3
    # sample keys and random permutation
    N = 6
    key = random.sample(range(1, 2^N), 2)
    print("Key: ", key)
    P = [random_permutation(2^N) for _ in range(2)]

    # prepare gates
    P1 = lambda x,y: P[0](x)
    P2 = lambda x,y: P[1](x)
    E = lambda x, y: P[0](x ^^ key[0]) ^^ key[1] ^^ P[1](x ^^ key[1]) ^^ key[1]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P1, P2]

    rnd = random_permutation(2^N)
    E_rnd = lambda x, y: rnd(x)
    GATES_rnd = [XOR, E_rnd, P1, P2]

    # prepare input nodes
    U = [u for u in range(2^N) for _ in range(2^N)]
    X = [x for _ in range(2^N) for x in range(2^N)]

    C_init = [U, X]
    RULES = [rule_is_normal,
             gen_rule_single_input([1, 2, 3]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 6, RULES, GATES_rnd)
    CI.search_periodic_circuit_gms(N, N, u_=key[1], compare_random=True)
    # => Period key[0] for u*=key[1]

def soem21_variant_search():
    # (unsuccessful) search for attacks on variant from conclusion
    # sample keys and random permutation
    N = 6
    key = random.sample(range(1, 2^N), 1)[0]
    print("Key: ", key)
    P = [random_permutation(2^N) for _ in range(2)]

    F = GF(2^N)
    MUL_2 = lambda x: (F.fetch_int(2)*F.fetch_int(x)).integer_representation()

    # prepare gates
    P1 = lambda x,y: P[0](x)
    P2 = lambda x,y: P[1](x)
    MUL_2_ = lambda x, y: MUL_2(x)
    E = lambda x, y: P[0](x ^^ key) ^^ key ^^ P[1](x ^^ MUL_2(key)) ^^ MUL_2(key)
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P1, P2, MUL_2_]

    rnd = random_permutation(2^N)
    E_rnd = lambda x, y: rnd(x)
    GATES_rnd = [XOR, E_rnd, P1, P2, MUL_2_]

    # prepare input nodes
    X = [x for x in range(2^N)]
    C_init = [X]

    RULES = [rule_is_normal,
             gen_rule_single_input([1, 2, 3, 4]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 6, RULES, GATES_rnd)
    CI.search_periodic_circuit(progress=True)


