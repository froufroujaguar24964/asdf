load("attack.sage")
load("helper_functions.sage")
load("rules.sage")

def LRWQ_search_gms():
    N = 5
    key = random.sample(range(2^N), 3)
    print(key)

    ED = [random_permutation(2^N, inverseToo=True) for _ in range(2^N)]
    E, D = [ED[i][0] for i in range(2^N)], [ED[i][1] for i in range(2^N)]

    T = random.sample(range(2^N), 1)[0]
    LRWQ = lambda x, y: E[key[2]](E[key[0]](x) ^^ E[key[1]](T))
    DEC = lambda x,y: D[key[-1]](x) # fix u*=key[2]
    XOR = lambda x, y: x ^^ y
    GATES = [XOR, LRWQ, DEC]

    rnd = random_permutation(2^N)
    def E_rnd(x, y): return rnd(x)
    GATES_random = [XOR, E_rnd, DEC]

    RULES = [rule_is_normal,
             gen_rule_single_input([1, 2]),
             gen_rule_number_of_oracles([([1], 1)]),
             gen_rule_inputs_to_output([0, 1, 2], []),
             rule_xors]

    # prepare input nodes
    X = [x for x in range(2^N)]
    a = random.sample(range(0, 2^N), 1)[0]
    A = [a for _ in range(2^N)]

    C_init = [X, A]
    print(a)

    CI = CircuitIterator(C_init, GATES, 7, RULES, GATES_random)
    CI.search_periodic_circuit(compare_random=True)
    #=> nothing




