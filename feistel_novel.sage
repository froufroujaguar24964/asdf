load("feistel_known.sage")

def feistel_4_FK_search():
    N = 4
    F = random_permutation(2^N)
    F_ = lambda x,y: F(x)
    K = [ZZ.random_element(2^N) for _ in range(4)]
    P = [lambda x, k=k: F(x)^^k for k in K]
    d = prepare(P, N)
    GATES = [d["XOR"], d["E_L"], d["E_R"], F_]
    GATES_random = [d["XOR"], d["E_L_random"], d["E_R_random"], F_]
    X = [x for x in range(2^N)]
    C_init = [X]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_single_input([3]),
             gen_rule_inputs_to_output([0], []),
             gen_rule_L_R_same_input(1, 2),
             gen_rule_number_of_oracles(MIN=[([1, 2], 1)],
                                        MAX=[(1, 1), (2, 1)])]

    print("expected period: ", K[1]^^F(K[0]))
    CI = CircuitIterator(C_init, GATES, 3, RULES, GATES_random)
    CI.search_periodic_circuit()

    a = d["a"]
    A = [a[0] for _ in range(2^N)]
    C_init = [X, A]
    RULES = [rule_is_normal, rule_xors,
             gen_rule_single_input([3]),
             gen_rule_inputs_to_output([0, 1], []),
             gen_rule_gates_depend_on_x([1,2]),
             gen_rule_L_R_same_input(1, 2),
             gen_rule_number_of_oracles(MIN=[([1, 2], 1)],
                                        MAX=[(1, 1), (2, 1)])]
    print("expected period: ", K[0]^^F(a[0]))
    CI = CircuitIterator(C_init, GATES, 6, RULES, GATES_random)
    CI.search_periodic_circuit(progress=True)

def feistel_5_FK_search():
    N = 4
    F, F_inv = random_permutation(2^N, inverseToo=True)
    F_ = lambda x,y: F(x)
    F_inv_ = lambda x,y: F_inv(x)
    K = [ZZ.random_element(2^N) for _ in range(5)]
    P = [lambda x, k=k: F(x)^^k for k in K]
    d = prepare(P, N)
    GATES = [d["XOR"], d["E_L"], d["E_R"], F_, F_inv_]
    GATES_random = [d["XOR"], d["E_L_random"], d["E_R_random"],
                    F_, F_inv_]
    X = [x for x in range(2^N)]
    C_init = [X]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_single_input([3, 4]), gen_rule_F_F_inv(3, 4),
             gen_rule_L_R_same_input(1, 2),
             gen_rule_gates_depend_on_x([1,2]),
             gen_rule_number_of_oracles(MIN=[([1, 2], 1)],
                                        MAX=[(1, 1), (2, 1)])]

    print("expected period: ", K[1]^^F(K[0]))
    CI = CircuitIterator(C_init, GATES, 6, RULES, GATES_random)
    CI.search_periodic_circuit(progress=True)


    GATES = [d["XOR"], d["E_L"], F_, F_inv_]
    GATES_random = [d["XOR"], d["E_L_random"], F_, F_inv_]
    RULES = [rule_xors, gen_rule_single_input([2, 3]),
             gen_rule_F_F_inv(2, 3), rule_is_normal,
             gen_rule_inputs_to_output([0, 1], []),
             gen_rule_number_of_oracles(MIN=[([1], 1)], MAX=[(1, 1)]),
             gen_rule_gates_depend_on_x([1,2,3])]

    s1 = K[1]^^F(K[0])
    S1 = [s1 for _ in range(2^N)]
    C_init = [X, S1]
    print("expected period: ", K[0]^^K[2])
    CI = CircuitIterator(C_init, GATES, 7, RULES, GATES_random)
    CI.search_periodic_circuit(progress=True)
