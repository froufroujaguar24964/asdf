load("helper_functions.sage")
load("attack.sage")
load("rules.sage")

def ecbc_search():
    N = 4
    E = [random_permutation(2^N) for _ in range(2)]
    MAC = lambda m1, m2: E[1](E[0](E[0](m1) ^^ m2))
    XOR = lambda x, y: x ^^y

    X = [x for x in range(2^N) for _ in range(2)]
    a = random.sample(range(2^N), 2)
    AB = [a[i] for _ in range(2^N) for i in range(2)]
    ANB = [a[1-i] for _ in range(2^N) for i in range(2)]

    C_init = [X, AB, ANB]
    GATES = [XOR, MAC]

    F = random_function(2^(2*N), 2^N)
    RF = lambda x, y: F(2^N * x + y)
    GATES_random = [XOR, RF]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_inputs_to_output([0], [[1,2]]),
             gen_rule_appearance_order(1,2),
             gen_rule_number_of_oracles(MIN=[([1], 1)])]

    CI = CircuitIterator(C_init, GATES, 1, RULES, GATES_random)
    CI.search_periodic_circuit()

def sum_ecbc_search():
    N = 6
    ED = [random_permutation(2^N, inverseToo=True) for _ in range(4)]
    E, D = [ED[i][0] for i in range(4)], [ED[i][1] for i in range(4)]
    MAC = lambda m1, m2: (E[1](E[0](E[0](m1) ^^ m2)) ^^
                          E[3](E[2](E[2](m1) ^^ m2)))
    XOR = lambda x, y: x ^^y
    F = random_function(2^(2*N), 2^N)
    RF = lambda x, y: F(2^N * x + y)

    U = [u for u in range(2^N) for _ in range(2^N)]
    X = [x for _ in range(2^N) for x in range(2^N)]
    a = random.sample(range(2^N), 2)
    A0 = [a[0] for _ in range(2^N) for _ in range(2^N)]
    A1 = [a[1] for _ in range(2^N) for _ in range(2^N)]

    C_init = [U, X, A0, A1]
    GATES = [XOR, MAC]
    GATES_random = [XOR, RF]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_inputs_to_output([0,1,2,3], []),
             gen_rule_appearance_order(2, 3),
             gen_rule_number_of_oracles(MIN=[([1], 1)], MAX=[(1,2)])]

    US = [E[0](a[0])^^E[0](a[1]), E[2](a[0])^^E[2](a[1])]
    US_ = [D[0](a[0]^^E[0](a[1])), D[2](a[0]^^E[2](a[1]))]
    print(f"Expected u*: {US}")
    print(f"Expected s: {US[0] ^^ US[1]}")
    print(f"Additional u*: {US_}")
    print(f"Additional s: {E[2](US_[0])^^E[2](a[1])^^a[0]},"
          f"{E[0](US_[1])^^E[0](a[1])^^a[0]}")
    CI = CircuitIterator(C_init, GATES, 4, RULES, GATES_random)
    CI.search_periodic_circuit_gms(N, N, compare_random=True,
                                   progress=True)
    # => circuit 612541

def pmac_plus_search():
    N = 4
    E0, E0_inv = random_permutation(2^N, inverseToo=True)
    E = [E0] + [random_permutation(2^N) for _ in range(3)]
    MUL_2 = lambda x: 2*x % 2^N # important: 0 -> 0
    b = random.sample(range(2^N), 2)
    MAC_1 = lambda m1, m2: (E[1](E[0](m1^^b[0]))^^
                            E[2](E[0](m1^^b[0])))
    MAC_2 = lambda m1, m2: (E[1](E[0](m1^^b[0])^^E[0](m2^^b[1]))^^
                            E[2](MUL_2(E[0](m1^^b[0]))
                                 ^^ E[0](m2^^b[1])))
    XOR = lambda x, y: x ^^y

    F_1 = random_function(2^N, 2^N)
    RF_1 = lambda x, y: F_1(x)
    F_2 = random_function(2^(2*N), 2^N)
    RF_2 = lambda x, y: F_2(2^N * x + y)

    U = [u for u in range(2^N) for _ in range(2^N)]
    X = [x for _ in range(2^N) for x in range(2^N)]

    C_init = [U, X]
    GATES = [XOR, MAC_1, MAC_2]
    GATES_random = [XOR, RF_1, RF_2]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_inputs_to_output([0,1], []),
             gen_rule_single_input([1]),
             gen_rule_number_of_oracles(MIN=[([1], 1), ([2], 1)],
                                        MAX=[(1, 1), (2, 1)])]

    u = E0_inv(0) ^^ b[0]
    s = b[0] ^^ b[1]
    print(f"u = {u}")
    print(f"s = {s}")
    CI = CircuitIterator(C_init, GATES, 3, RULES, GATES_random)
    CI.search_periodic_circuit_gms(N, N, compare_random=True)



def PDMMAC_search():
    N = 4
    P, P_inv = random_permutation(2^N, inverseToo=True)
    key = random.sample(range(2^N), 1)[0]
    print(key)

    F = GF(2^N)
    MUL_2 = lambda x: (F.fetch_int(2)*F.fetch_int(x)).integer_representation()
    MUL_3 = lambda x: (F.fetch_int(3)*F.fetch_int(x)).integer_representation()


    MAC = lambda x,y: P_inv(P(key ^^ x) ^^ x ^^ MUL_3(key)) ^^ MUL_2(key)
    XOR = lambda x, y: x ^^y
    P_ = lambda x,y: P(x)
    P_inv_ = lambda x,y: P_inv(x)

    GATES = [XOR, MAC, P_, P_inv_]

    rnd = random_function(2^N, 2^N)
    MAC_rnd = lambda x, y: rnd(x)
    GATES_random = [XOR, MAC_rnd, P_, P_inv_]

    X = [x for x in range(2^N)]
    C_init = [X]

    RULES = [rule_is_normal,
             gen_rule_single_input([1, 2, 3]),
             gen_rule_number_of_oracles(MIN=[([1], 1)]),
             rule_xors]

    # search for periodic circuit
    CI = CircuitIterator(C_init, GATES, 7, RULES, GATES_random)
    CI.search_periodic_circuit()
    # => nothing

def light_mac_search():
    N, s = 10, 4
    t = N-s

    E1, E2 = [random_permutation(2^N) for _ in range(2)]
    pad1, pad2 = 1 << t, 1 << s

    MAC_1 = lambda x, y: E2(x ^^ pad2)
    MAC_2 = lambda x, y: E2(y ^^ pad2 ^^ E1(pad1 ^^ x))
    XOR = lambda x, y: x ^^y

    F_1 = random_function(2^t, 2^t)
    RF_1 = lambda x, y: F_1(x)
    F_2 = random_function(2^(2*t), 2^t)
    RF_2 = lambda x, y: F_2(2^t * x + y)

    U = [u for u in range(2^t) for _ in range(2^t)]
    X = [x for _ in range(2^t) for x in range(2^t)]

    C_init = [U, X]
    GATES = [XOR, MAC_1, MAC_2]
    GATES_random = [XOR, RF_1, RF_2]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_inputs_to_output([0,1], []),
             gen_rule_single_input([1]),
             gen_rule_number_of_oracles(MIN=[([1, 2], 1)])]

    CI = CircuitIterator(C_init, GATES, 3, RULES, GATES_random)
    CI.search_periodic_circuit_gms(t, t, compare_random=True)
    # => f(u, x) = MAC(x) ^^ MAC(u, x)







