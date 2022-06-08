load("helper_functions.sage")
load("attack.sage")
load("rules.sage")

def misty_L(F):
    def ENC(L, R):
        for f in F:
            L, R = R, R ^^ f(L)
        return L, R
    return ENC

def misty_R(F):
    def ENC(L, R):
        for f in F:
            h = f(L)
            L, R = R^^h, h
        return L, R
    return ENC

def prepare(N, r, LR):
    d = dict()
    F, F_inv = random_permutation(2^N, inverseToo=True)
    K = [ZZ.random_element(2^N) for _ in range(r)]
    if LR == "L":
        ENC = misty_L([lambda x, k=k: F(x)^^k for k in K])
    elif LR == "R":
        ENC = misty_R([lambda x, k=k: F(x)^^k for k in K])
    E_L = lambda l, r: ENC(l, r)[0]
    E_R = lambda l, r: ENC(l, r)[1]
    XOR = lambda x,y: x^^y
    F_ = lambda x,y: F(x)
    F_inv_ = lambda x,y: F_inv(x)
    GATES = [XOR, E_L, E_R, F_, F_inv_]
    RP, RP_inv = random_permutation(2^(2*N), inverseToo=True)
    E_L_random = lambda x, y: RP(2^N * x + y) >> N
    E_R_random = lambda x, y: RP(2^N * x + y) % 2^N
    GATES_random = [XOR, E_L_random, E_R_random, F_, F_inv_]
    X = [x for x in range(2^N)]
    a = ZZ.random_element(2^N)
    A = [a for _ in range(2^N)]
    d["GATES"] = GATES
    d["GATES_random"] = GATES_random
    d["F"], d["K"], d["X"], d["A"], d["a"] = F, K, X, A, a
    return d

def misty_5_L_FK_search():
    N = 4
    d = prepare(N, 5, "L")
    X, K, F, A, a = d["X"], d["K"], d["F"], d["A"], d["a"]
    GATES, GATES_random = d["GATES"], d["GATES_random"]

    C_init = [X, A]
    RULES = [rule_is_normal, rule_xors, gen_rule_F_F_inv(3, 4),
             gen_rule_inputs_to_output([0, 1], []),
             gen_rule_single_input([3,4]),
             gen_rule_number_of_oracles(MIN=[([1, 2], 1)])]
    print("expected period: ", F(a)^^K[1])
    CI = CircuitIterator(C_init, GATES, 3, RULES, GATES_random)
    CI.search_periodic_circuit()

    C_init = [X]
    RULES = [rule_is_normal, rule_xors, gen_rule_F_F_inv(3, 4),
             gen_rule_single_input([3,4]),
             gen_rule_number_of_oracles(MIN=[([1, 2], 1)])]
    print("expected period: ", F(K[0])^^K[2])
    CI = CircuitIterator(C_init, GATES, 4, RULES, GATES_random)
    CI.search_periodic_circuit()

    C_init = [X]
    RULES = [rule_is_normal, rule_xors, gen_rule_F_F_inv(3, 4),
             gen_rule_single_input([3,4]),
             gen_rule_L_R_same_input(1, 2),
             gen_rule_number_of_oracles(MIN=[([1, 2], 1)],
                                        MAX=[(1, 1), (2, 1)]),]
    print("expected period: ", K[0]^^K[1])
    print("expected period: ", K[0])
    CI = CircuitIterator(C_init, GATES, 6, RULES, GATES_random)
    CI.search_periodic_circuit(progress=True)

    print("expected period: ", K[0]^^K[1]^^K[2]^^F(K[0]))
    CI = CircuitIterator(C_init, GATES, 7, RULES, GATES_random)
    CI.search_periodic_circuit(progress=True)

def misty_4_R_FK_search():
    N = 5
    d = prepare(N, 4, "R")
    X, K, F = d["X"], d["K"], d["F"]
    GATES, GATES_random = d["GATES"], d["GATES_random"]
    C_init = [X]
    RULES = [rule_is_normal, rule_xors, gen_rule_F_F_inv(3, 4),
             gen_rule_single_input([3,4]),
             gen_rule_L_R_same_input(1, 2),
             gen_rule_number_of_oracles(MIN=[([1, 2], 1)],
                                        MAX=[(1, 1), (2, 1)])]
    print("expected period: ", K[0])
    CI = CircuitIterator(C_init, GATES, 5, RULES, GATES_random)
    CI.search_periodic_circuit(progress=True)
