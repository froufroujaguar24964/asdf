# rules map C -> True/False
# assuming C without last gate fulfilled the rule

def rule_is_normal(C):
    v = C.num_verts-1
    # discard if unordered
    if not C.node_order(v-1, v): return False
    # discard if not onefold
    for u in range(C.q, v):
        if (C.gates[v] == C.gates[u] and C.left(v) == C.left(u) and
            C.right(v) == C.right(u)):
            return False
    # loose end check is already fast in circuit implementation
    if not C.has_no_loose_ends(): return False
    return True

def gen_rule_single_input(G):
    """
    G: List of gates that take only a single input.
    """
    def rule_single_input(C):
        v = C.num_verts-1
        if C.gates[v] in G:
            if C.left(v) != C.right(v): return False
        return True
    return rule_single_input

def gen_rule_number_of_oracles(MIN=None, MAX=None):
    """
    MIN: List of tuples (G, i): Combined, gates from G must appear
    at least i times in the complete circuit.
    MAX: List of tuples (g, i): Gate g must not appear more then i
    times in the complete circuit.
    """
    if MIN == None: MIN = []
    if MAX == None: MAX = []
    def rule_number_of_oracles(C):
        n = C.num_verts
        if n == C.k + C.q:
            for G, i in MIN:
                if sum(C.gates.count(g) for g in G) < i:
                    return False
        for g, i in MAX:
            if C.gates.count(g) > i: return False
        return True
    return rule_number_of_oracles

def rule_xors(C):
    """
    Discard cirucuits that compute useless XORs.
    """
    n = C.num_verts
    v = n-1
    if C.gates[v] == 0:
        # a xor b => a < b
        if not C.node_order(C.left(v), C.right(v)): return False
        # no (a xor b) xor a etc.
        l, r = C.left(v), C.right(v)
        if C.xor_sums[l].intersection(C.xor_sums[r]) != set([]):
            return False
        # no equivalent xor sums
        if C.xor_sums[v] in C.xor_sums[:v]: return False
    return True

def gen_rule_inputs_to_output(L, K):
    """
    L: List of inputs that have to be connected to the output
    K: List of lists of inputs for which at least one has to be
    connected to the output. This presumes that C is normal.
    """
    def rule_check_inputs_to_output(C):
        n = C.num_verts
        if n != C.q + C.k: return True
        for v in L:
            if (v not in C.lefts) and (v not in C.rights):
                return False
        for k in K:
            for v in k:
                if v in C.lefts or v in C.rights:
                    break
            else:
                return False
        return True
    return rule_check_inputs_to_output

def gen_rule_appearance_order(a, b):
    """
    Check that a appears before b. This presumes a < b.
    """
    def rule_apperance_order(C):
        n = C.num_verts
        v = n-1
        l, r = C.left(v), C.right(v)
        # a as left or no b => all good
        if (l != a) and (l == b or r == b):
            # a xor b does not count as apperance
            for u in range(C.q, v):
                # a appeared with non xor gate => all good
                if (C.gates[u] != 0 and C.left(u) == a or
                    C.right(u) == a):
                    break
                # a appeared with xor gate and no b => all good
                if (C.gates[u] == 0 and
                    (C.left(u) == a or C.right(u) == a) and
                    C.left(u) != b and C.right(u) != b):
                    break
            else:
                return False
        return True
    return rule_apperance_order

def gen_rule_F_F_inv(g_F, g_Finv):
    """
    Generate rule that discards if single input gates g_F and
    g_Finv uncompute each other.
    """
    def rule_F_F_inv(C):
        v = C.num_verts-1
        g = C.gates[v]
        l, r = C.left(v), C.right(v)
        if g == g_F:
            if C.gates[l] == g_Finv: return False
        if g == g_Finv:
            if C.gates[l] == g_F: return False
        return True
    return rule_F_F_inv

def gen_rule_L_R_same_input(g_L, g_R):
    """
    Generate rule that discards if gate g_L and g_R do not
    have the same inputs. That presumes that both g_L and
    g_R only appear ones.
    """
    def rule_L_R_same_input(C):
        v = C.num_verts-1
        # left and right Oracle gates must have same input
        if C.gates[v] in [g_L, g_R]:
            for u in range(C.q, v):
                if C.gates[u] in [g_L, g_R]:
                    if (C.left(v) != C.left(u) or
                        C.right(v) != C.right(u)):
                        return False
        return True
    return rule_L_R_same_input

def gen_rule_gates_depend_on_x(G):
    """
    Generate rule that discards if a gate g in G does not
    depend on the first input node.
    """
    def rule_gates_depend_on_x(C):
        v = C.num_verts-1
        if C.gates[v] in G:
            dag = C.make_graph()
            if dag.distance(v, 0) == +Infinity: return False
        return True
    return rule_gates_depend_on_x



