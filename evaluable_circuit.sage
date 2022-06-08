load("circuit.sage")

class EvaluableCircuit(Circuit):
    def __init__(self, X, GATES, k):
        """
        X: list of evaluations of input nodes
        GATES: list of gate functions. GATES[0] must be XOR
        k: size of circuit
        """
        super().__init__(len(X), len(GATES), k)
        self.evaluation = deepcopy(X)
        for _ in range(k): self.evaluation.append(None)
        self.GATES = GATES

    def eval(self, v):
        if self.evaluation[v] == None:
            L = self.eval(self.left(v))
            R = self.eval(self.right(v))
            g = self.GATES[self.gates[v]]
            self.evaluation[v] = list(map(g, L, R))
        return self.evaluation[v]

    def delete_last_gate(self):
        n = self.num_verts
        if super().delete_last_gate() == False:
            return False
        self.evaluation[n-1] = None

    def periods(self):
        n = self.num_verts
        if n != self.q + self.k:
            return False

        V = self.eval(n-1)
        S = []
        for s in range(1, len(self.evaluation[0])):
            for x in range(len(self.evaluation[0])):
                if V[x] != V[x ^^ s]:
                    break
            else:
                S.append(s)
        return S

    def periods_gms(self, low, high):
        """
        Compute periods for Grover-Meets-Simon case.
        """
        n = self.num_verts
        if n != self.q + self.k:
            return False

        V = self.eval(n-1)[low:high]
        S = []
        for s in range(1, len(self.evaluation[0][low:high])):
            for x in range(len(self.evaluation[0][low:high])):
                if V[x] != V[x ^^ s]:
                    break
            else:
                S.append(s)
        return S

    def from_int(self, c):
        n = self.num_verts
        for _ in range(n-self.q):
            self.delete_last_gate()
        super().from_int(c)
        for i in range(self.q, self.q+self.k): self.eval(i)
