load("attack.sage")
load("rules.sage")
load("helper_functions.sage")

def Feistel(F, inverseToo=False):
    """
    Build Feistel Network with len(F) rounds and internal Functinos
    F[0], ..., F[-1] (and when indicated its inverse).
    """
    def E(l, r):
        for f in F:
            l, r = r, l ^^ f(r)
        return l, r
    def D(l, r):
        l, r = r, l
        for f in F[::-1]:
            l, r = r, l ^^ f(r)
        l, r = r, l
        return l, r
    return (E, D) if inverseToo else E

def prepare(F, N):
    d = dict()
    Enc, Dec = Feistel(F, inverseToo=True)
    # prepare gates
    d["E_L"] = lambda l, r: Enc(l, r)[0]
    d["E_R"] = lambda l, r: Enc(l, r)[1]
    d["D_L"] = lambda l, r: Dec(l, r)[0]
    d["D_R"] = lambda l, r: Dec(l, r)[1]
    d["XOR"] = lambda x,y: x^^y

    # prepare random versions of gates
    RP, RP_inv = random_permutation(2^(2*N), inverseToo=True)
    d["E_L_random"] = lambda x, y: RP(2^N * x + y) >> N
    d["E_R_random"] = lambda x, y: RP(2^N * x + y) % 2^N
    d["D_L_random"] = lambda x, y: RP_inv(2^N * x + y) >> N
    d["D_R_random"] = lambda x, y: RP_inv(2^N * x + y) % 2^N

    # prepare input nodes
    a = random.sample(range(2^N), 2)
    d["a"] = a
    d["AB"] = [a[i] for _ in range(2^N) for i in range(2)]
    d["ANB"] = [a[1-i] for _ in range(2^N) for i in range(2)]
    return d

def rule_Dec(C):
    v = C.num_verts-1
    l, r = C.left(v), C.right(v)
    g = C.gates[v]

    # Dec only after Enc
    if g in [3, 4]:
        dag = C.make_graph()
        if not any([dag.distance(v, u) != +Infinity
                    for u in range(C.q, v)
                    if C.gates[u] in [1,2]]):
            return False

    # no Dec(Enc_L, Enc_R)
    if g in [3, 4]:
        if C.gates[l] == 1 and C.gates[r] == 2:
            if (C.left(l) == C.left(r) and
                C.right(l) == C.right(r)):
                return False
    return True

def feistel_3_search():
    # preparations
    N = 4
    F = [random_permutation(2^N) for _ in range(3)]
    d = prepare(F, N)
    GATES = [d["XOR"], d["E_L"], d["E_R"]]
    GATES_random = [d["XOR"], d["E_L_random"], d["E_R_random"]]
    X = [x for x in range(2^N) for _ in range(2)]
    C_init = [X, d["AB"], d["ANB"]]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_inputs_to_output([0], [[1,2]]),
             gen_rule_appearance_order(1, 2),
             gen_rule_gates_depend_on_x([1,2]),
             gen_rule_L_R_same_input(1, 2),
             gen_rule_number_of_oracles(MIN=[([1, 2], 1)],
                                        MAX=[(1, 1), (2, 1)])]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 2, RULES, GATES_random)
    CI.search_periodic_circuit() # => circuits 487 and 491

def feistel_4_search():
    N = 4
    F = [random_permutation(2^N) for _ in range(4)]
    d = prepare(F, N)
    GATES = [d["XOR"], d["E_L"], d["E_R"], d["D_L"], d["D_R"]]
    GATES_random = [d["XOR"], d["E_L_random"], d["E_R_random"],
                    d["D_L_random"], d["D_R_random"]]
    X = [x for x in range(2^N) for _ in range(2)]
    C_init = [X, d["AB"], d["ANB"]]

    RULES = [rule_xors, rule_is_normal,
             gen_rule_inputs_to_output([0], [[1,2]]),
             gen_rule_appearance_order(1, 2), rule_Dec,
             gen_rule_gates_depend_on_x([1,2,3,4]),
             gen_rule_L_R_same_input(1, 2),
             gen_rule_L_R_same_input(3, 4),
             gen_rule_number_of_oracles(MIN=[([1, 2, 3, 4], 1)],
                            MAX=[(1, 1), (2, 1), (3, 1), (4, 1)])]

    CI = CircuitIterator(C_init, GATES, 6, RULES, GATES_random)
    CI.search_periodic_circuit(progress=True)

def feistel_6_FK_search():
    N = 4
    F = random_permutation(2^N)
    F_ = lambda x,y: F(x)
    K = [ZZ.random_element(2^N) for _ in range(6)]
    P = [lambda x, k=k: F(x)^^k for k in K]
    d = prepare(P, N)
    GATES = [d["XOR"], d["E_L"], d["E_R"], d["D_L"], d["D_R"], F_]
    GATES_random = [d["XOR"], d["E_L_random"], d["E_R_random"],
                    d["D_L_random"], d["D_R_random"], F_]
    X = [x for x in range(2^N) for _ in range(2)]
    C_init = [X, d["AB"], d["ANB"]]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_single_input([5]),
             gen_rule_inputs_to_output([0], [[1,2]]),
             gen_rule_appearance_order(1, 2), rule_Dec,
             gen_rule_L_R_same_input(3, 4),
             gen_rule_gates_depend_on_x([1,2,3,4]),
             gen_rule_L_R_same_input(1, 2),
             gen_rule_number_of_oracles(MIN=[([1, 2, 3, 4], 1)],
                            MAX=[(1, 1), (2, 1), (3, 1), (4, 1)])]

    #CI = CircuitIterator(C_init, GATES, 15, RULES, GATES_random)
    #CI.search_periodic_circuit()
    # should find C but far out of reach in terms of runtime

    C = EvaluableCircuit(C_init, GATES, 15)
    C.add_gate(5, 0, 0) # 3: F(x)
    C.add_gate(0, 1, 3) # 4: F(x) ^^ ab
    C.add_gate(1, 4, 0) # 5: E_L(F(x) ^^ ab, x) = L'
    C.add_gate(2, 4, 0) # 6: E_R(F(x) ^^ ab, x) = R'
    C.add_gate(0, 1, 5) # 7: L' ^^ ab
    C.add_gate(0, 2, 7) # 8: L' ^^ ab ^^ anb
    C.add_gate(5, 5, 5) # 9: F(L')
    C.add_gate(0, 6, 9) # 10: R' ^^ F(L')
    C.add_gate(5, 8, 8) # 11: F(L' ^^ ab ^^ anb)
    C.add_gate(0, 10, 11) # 12: R' ^^ F(L') ^^ F(L' ^^ ab ^^ anb)
    C.add_gate(3, 8, 12) # 13: L
    C.add_gate(4, 8, 12) # 14: R
    C.add_gate(5, 14, 14) # 15: F(R)
    C.add_gate(0, 1, 13) # 16: L ^^ ab
    C.add_gate(0, 15, 16) # 17: L ^^ ab ^^ F(R)
    print(2*(F(d["a"][0]^^K[0])^^F(d["a"][1]^^K[0]))^^1)
    print(C.periods())
