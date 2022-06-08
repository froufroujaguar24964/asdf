load("helper_functions.sage")
load("attack.sage")
load("rules.sage")

def hctr_search():
    N = 4
    E = random_permutation(2^N)
    H = random_function(2^(2*N), 2^N)
    def hctr(h, e, T, M1, M2):
        IV = h(2^N * T + M2) ^^ M1 ^^ e(h(2^N*T + M2) ^^ M1)
        c2 = e(IV ^^ 1) ^^ M2
        c1 = e(h(2^N * T + M2)) ^^ h(2^N * T + c2)
        return c1, c2
    T = random.sample(range(2^N), 2)

    hctr_T0 = lambda x, y: hctr(H, E, T[0], x, y)[1]
    hctr_T1 = lambda x, y: hctr(H, E, T[1], x, y)[1]
    XOR = lambda x, y: x ^^y

    X = [x for x in range(2^N)]
    m2 = ZZ.random_element(2^N)
    M2 = [m2 for _ in range(2^N)]
    C_init = [X, M2]
    GATES = [XOR, hctr_T0, hctr_T1]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_inputs_to_output([0, 1], [])]
    print(f"Expected period: s = "
          f"{H(2^N * T[0] + m2) ^^ H(2^N * T[1] + m2)}")
    CI = CircuitIterator(C_init, GATES, 3, RULES)
    CI.search_periodic_circuit()


def tweakable_hctr_search():
    N = 4
    E = random_permutation(2^N)
    H = random_function(2^N, 2^N)
    def tweakable_hctr(h, e, H1, M1, M2):
        IV = e(h(M2)^^M1^^H1)^^h(M2)^^M1^^H1
        c2 = e(IV ^^ 1)^^M2
        return c2

    T = ZZ.random_element(2^N)
    hctr = lambda x, y: tweakable_hctr(H, E, T, x, y)
    XOR = lambda x, y: x ^^y

    X = [x for x in range(2^N)]
    m = random.sample(range(2^N), 2)
    M1 = [m[0] for _ in range(2^N)]
    M2 = [m[1] for _ in range(2^N)]
    C_init = [X, M1, M2]
    GATES = [XOR, hctr]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_inputs_to_output([0, 1, 2], [])]
    print(f"Expected period: s = {H(m[0]) ^^ H(m[1])}")
    CI = CircuitIterator(C_init, GATES, 3, RULES)
    CI.search_periodic_circuit()

def hch_search():
    N = 4
    E = random_permutation(2^N)
    H = random_function(2^N, 2^N)
    def hch(h, e, M1, M2):
        S = e(e(h(M2)^^M1)^^h(M2)^^M1)
        c2 = e(S)^^M2
        return c2

    hch_gate = lambda x, y: hch(H, E, x, y)
    XOR = lambda x, y: x ^^y

    X = [x for x in range(2^N)]
    m = random.sample(range(2^N), 2)
    M1 = [m[0] for _ in range(2^N)]
    M2 = [m[1] for _ in range(2^N)]
    C_init = [X, M1, M2]
    GATES = [XOR, hch_gate]

    RULES = [rule_is_normal, rule_xors,
             gen_rule_inputs_to_output([0, 1, 2], [])]
    CI = CircuitIterator(C_init, GATES, 3, RULES)
    CI.search_periodic_circuit()
