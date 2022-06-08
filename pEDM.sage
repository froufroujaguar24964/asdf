load("attack.sage")
load("helper_functions.sage")
load("rules.sage")

def pEDM_search():
    N = 5
    key = random.sample(range(1, 2^N), 2)
    print("Keys: ", key)
    P = random_permutation(2^N)


    # prepare gates
    P_ = lambda x,y: P(x)
    E = lambda x, y: P(P(x^^key[0]) ^^ x ^^ key[0] ^^ key[1]) ^^ key[0]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P_]

    F_1 = random_function(2^N, 2^N)
    RF_1 = lambda x, y: F_1(x)
    GATES_random = [XOR, RF_1, P_]


    # prepare input nodes
    X = [x for x in range(2^N)]
    C_init = [X]

    RULES = [rule_is_normal,
             gen_rule_single_input([1,2]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 8, RULES, GATES_random)
    CI.search_periodic_circuit(progress=True)
    # => nothing


def pEDM_search_gms():
    N = 4
    key = random.sample(range(1, 2^N), 2)
    print("Keys: ", key)
    P = random_permutation(2^N)

    # prepare gates
    P_ = lambda x,y: P(x)
    E = lambda x, y: P(P(x^^key[0]) ^^ x ^^ key[0] ^^ key[1]) ^^ key[0]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P_]

    F_1 = random_function(2^N, 2^N)
    RF_1 = lambda x, y: F_1(x)
    GATES_random = [XOR, RF_1, P_]

    # prepare input nodes
    U = [u for u in range(2^N) for _ in range(2^N)]
    X = [x for _ in range(2^N) for x in range(2^N)]

    C_init = [U, X]

    RULES = [rule_is_normal,
             gen_rule_inputs_to_output([0,1], []),
             gen_rule_single_input([1,2]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 6, RULES, GATES_random)
    CI.search_periodic_circuit_gms(N, N, compare_random=True)
    # => u=key[1], s=key[0]


def EDM_search_gms():
    N = 5
    key = random.sample(range(1, 2^N), 2)
    print("Keys: ", key)

    ED = [random_permutation(2^N, inverseToo=True) for _ in range(2^N)]
    E, D = [ED[i][0] for i in range(2^N)], [ED[i][1] for i in range(2^N)]

    # prepare gates
    ENC = lambda x, y: E[key[1]](E[key[0]](x) ^^ x)
    DEC = lambda x, y: D[key[1]](x) # fix u*=key[1] for DEC gate
    XOR = lambda x,y: x^^y
    GATES = [XOR, ENC, DEC]

    F_1 = random_function(2^N, 2^N)
    RF_1 = lambda x, y: F_1(x)
    GATES_random = [XOR, RF_1, DEC]

    # prepare input nodes
    X = [x for x in range(2^N)]
    a0 = random.sample(range(1, 2^N), 1)[0]
    print(a0)
    A = [a0 for _ in range(2^N)]

    C_init = [X, A]

    RULES = [rule_is_normal,
             gen_rule_inputs_to_output([0,1], []),
             gen_rule_single_input([1, 2]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 6, RULES, GATES_random)
    CI.search_periodic_circuit(compare_random=True)
    # => nothing


def EDMD_search_gms():
    N = 5
    key = random.sample(range(1, 2^N), 2)
    print("Keys: ", key)

    ED = [random_permutation(2^N, inverseToo=True) for _ in range(2^N)]
    E, D = [ED[i][0] for i in range(2^N)], [ED[i][1] for i in range(2^N)]

    # prepare gates
    ENC = lambda x, y: E[key[1]](E[key[0]](x)) ^^ E[key[0]](x)
    #DEC = lambda x, y: D[key[0]](x) # fix u*=key[0] for DEC gate
    DEC = lambda x, y: D[key[1]](x) # fix u*=key[1] for DEC gate
    XOR = lambda x,y: x^^y
    GATES = [XOR, ENC, DEC]

    F_1 = random_function(2^N, 2^N)
    RF_1 = lambda x, y: F_1(x)
    GATES_random = [XOR, RF_1, DEC]

    # prepare input nodes
    X = [x for x in range(2^N)]
    a0 = random.sample(range(1, 2^N), 1)[0]
    print(a0)
    A = [a0 for _ in range(2^N)]

    C_init = [X, A]

    RULES = [rule_is_normal,
             gen_rule_inputs_to_output([0,1], []),
             gen_rule_single_input([1, 2]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 7, RULES, GATES_random)
    CI.search_periodic_circuit(compare_random=True)
    # => nothing
