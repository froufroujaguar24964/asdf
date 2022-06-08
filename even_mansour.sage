load("attack.sage")
load("helper_functions.sage")
load("rules.sage")

def even_mansour_search():
    # sample keys and random permutation
    N = 4
    key = random.sample(range(1, 2^N), 2)
    print("Keys: ", key)
    P = random_permutation(2^N)

    # prepare gates
    P_ = lambda x,y: P(x)
    E = lambda x, y: P(x ^^ key[0]) ^^ key[1]
    XOR = lambda x,y: x^^y
    GATES = [XOR, E, P_]

    # prepare input nodes
    X = [x for x in range(2^N)]
    C_init = [X]

    RULES = [rule_is_normal,
             gen_rule_single_input([1,2]),
             gen_rule_number_of_oracles([([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 3, RULES)
    CI.search_periodic_circuit()
