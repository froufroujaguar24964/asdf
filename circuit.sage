class Circuit:
    """
    Base class for circuits.
    """
    def __init__(self, q, g, k):
        """
        q: number of input nodes
        g: number of gate functions
        k: size of circuit
        """
        self.gates = [None for _ in range(q)]
        self.depths = [0 for _ in range(q)]
        self.lefts = [None for _ in range(q)]
        self.rights = [None for _ in range(q)]
        self.xor_sums = [set([i]) for i in range(q)]
        for _ in range(k): self.gates.append(None)
        for _ in range(k): self.depths.append(None)
        for _ in range(k): self.lefts.append(None)
        for _ in range(k): self.rights.append(None)
        for _ in range(k): self.xor_sums.append(None)
        self.q = q
        self.g = g
        self.k = k
        self.num_verts = q

    def make_graph(self):
        """
        Generate dag for self.
        """
        dag = DiGraph(self.q, multiedges=False)
        for l, r in zip(self.lefts[self.q:], self.rights[self.q:]):
            if l == None or r == None: break
            v = dag.add_vertex()
            if l == r:
                dag.add_edge(v, l, label=3)
            else:
                dag.add_edge(v, l, label=1)
                dag.add_edge(v, r, label=2)
        return dag


    def __repr__(self):
        return f"({self.q}, {self.g}, {self.k}) Circuit"

    def show(self, gate_labels=True, figsize=[10,10]):
        """
        Show self either with index of gates as label or with
        internal labels i.e. 0, ..., q+k-1.
        """
        dag = self.make_graph()
        # relabel the nodes (only) in the plot as disscussed in
        # https://groups.google.com/g/sage-devel/c/Dfxpjk1q6f8
        vertex_colors = {"lightblue": [i for i in range(self.q)]}
        Gplot = dag.graphplot(layout="acyclic", vertex_size=800,
                                   edge_labels=True, iterations=1,
                                   vertex_colors=vertex_colors)
        # Extract relevant components
        node_list = Gplot._nodelist
        pos_dict = Gplot._pos
        # Define list or dict of labels (same length as node_list)
        label_list = ([i for i in range(self.q)] +
                      [g for i, g in enumerate(self.gates[self.q:])])
        # Modify vertex labels
        if gate_labels:
            Gplot._plot_components['vertex_labels'] = (
            [text(label, pos_dict[node], rgbcolor=(0,0,0), zorder=8)
             for node,label in zip(node_list,label_list)])
        Gplot.show(figsize=figsize)

    def delete_last_gate(self):
        n = self.num_verts
        if n <= self.q:
            return False
        self.depths[n-1] = None
        self.lefts[n-1] = None
        self.rights[n-1] = None
        self.gates[n-1] = None
        self.xor_sums[n-1] = None
        self.num_verts = n-1

    def add_gate(self, g, left, right):
        """
        g: index of gate function
        left: left predecessor
        right: right predecessor
        """
        n = self.num_verts
        if n >= self.q+self.k:
            return False
        self.gates[n] = g
        self.lefts[n] = left
        self.rights[n] = right
        if g == 0: # XOR=0
            L, R = self.xor_sums[left], self.xor_sums[right]
            self.xor_sums[n] = L.union(R)
        else:
            self.xor_sums[n] = set([n])
        self.num_verts = n+1

    def add_random_gate(self):
        n = self.num_verts
        g = choice(range(self.g))
        left, right = choice(range(n)), choice(range(n))
        self.add_gate(g, left, right)

    def random_circuit(self):
        n = self.num_verts
        for _ in range(n-self.q):
            self.delete_last_gate()
        for _ in range(self.k): self.add_random_gate()

    def to_int(self):
        n = self.num_verts
        if n != self.q+self.k:
            return False
        num = 0
        for i in range(self.k):
            v = self.q + i
            offset = (self.g^(self.k-i-1) *
                      rising_factorial(self.q+i+1, self.k-i-1)^2)
            num += (offset * (self.right(v) + self.left(v)*(self.q+i)
                              + self.gates[v]*(self.q+i)^2))
        return num

    def from_int(self, num):
        for i in range(self.k):
            offset = (self.g^(self.k-i-1) *
                      rising_factorial(self.q+i+1, self.k-i-1)^2)
            right = (num // offset) % (self.q+i)
            left = ((num // offset) // (self.q+i)) % (self.q+i)
            gate = ((num // offset) // ((self.q+i)^2)) % (self.g)
            self.add_gate(gate, left, right)

    def depth(self, v):
        if self.depths[v] == None:
            self.depths[v] = max(self.depth(self.left(v)),
                                 self.depth(self.right(v))) + 1
        return self.depths[v]

    def left(self, v):
        return self.lefts[v]

    def right(self, v):
        return self.rights[v]

    def node_order(self, u, v):
        """
        Return True if u prec v in C.
        """
        if u == v:
            return False
        if self.depth(u) != self.depth(v):
            return self.depth(u) < self.depth(v)
        if u < self.q:
            return u < v
        if self.gates[u] != self.gates[v]:
            return self.gates[u] < self.gates[v]
        if self.left(u) != self.left(v):
            return self.node_order(self.left(u), self.left(v))
        return self.node_order(self.right(u), self.right(v))

    def is_ordered(self):
        n = self.num_verts
        for v in range(self.q, n-1):
            if not self.node_order(v, v+1): return False
        return True

    def is_onefold(self):
        n = self.num_verts
        for v in range(self.q, n):
            for u in range(self.q, v):
                if (self.gates[v] == self.gates[u] and
                    self.left(v) == self.left(u) and
                    self.right(v) == self.right(u)):
                    return False
        return True

    def has_no_loose_ends(self):
        n = self.num_verts
        loose_ends = [v for v in range(self.q, n)
                      if (v not in self.lefts and
                          v not in self.rights)]
        if len(loose_ends) > 1 + (self.k - (n - self.q)):
            return False
        return True

    def is_normal(self):
        return (self.is_onefold() and self.has_no_loose_ends() and
                self.is_ordered())
