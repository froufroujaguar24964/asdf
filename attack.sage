load("evaluable_circuit.sage")
from tqdm import tqdm
from time import sleep

class CircuitIterator:
    def __init__(self, X, GATES, k, RULES, GATES_random=None):
        """
        X, GATES, K as for EvaluableCircuit. GATES[0] must be XOR
        RULES: list of rules i.e. functions that take as input a
        circuit and output True/False
        GATES_random: random versions of GATES. Can be used to
        identify trivial periods
        """
        self.C = EvaluableCircuit(X, GATES, k)
        self.C_random = None
        if GATES_random:
            assert len(GATES) == len(GATES_random), \
                "|GATES|!= |GATES_random|"
            self.C_random = EvaluableCircuit(X, GATES_random, k)
        self.counter = 0
        self.is_good_counter = 0
        self.is_good_leaf_counter = 0
        self.RULES = RULES
        self.reset()

    def reset(self):
        """
        Change self.C to first good circuit.
        """
        C = self.C
        n = C.num_verts
        for _ in range(n-C.q):
            C.delete_last_gate()
        for i in range(C.k):
            C.add_gate(0, 0, 0)
            # x xor x cannot be good
            # therefore we do not skip good circuits
            self.next(C.q+i)
        self.counter = 0

    def next(self, v):
        """
        Use internaly to change self.C to next good (parital) circuit. Return
        True if final circuit is reached.
        """
        C = self.C
        if v < C.q:
            return True
        while True:
            g, left, right = C.gates[v], C.left(v), C.right(v)
            C.delete_last_gate()
            if right < v-1:
                C.add_gate(g, left, right+1)
            elif left < v-1:
                C.add_gate(g, left+1, 0)
            elif g < C.g-1:
                C.add_gate(g+1, 0, 0)
            else:
                flag = self.next(v-1)
                C.add_gate(0, 0, 0)
                if flag: return True
            if self.is_good():
                break

    def next_circuit(self):
        """
        Change self.C to next good circuit.
        """
        self.counter += 1
        flag = self.next(self.C.q+self.C.k-1)
        if flag:
            # reached final circuit
            return False

    def is_good(self):
        """
        Check if self.C complies with all rules.
        """
        self.is_good_counter += 1
        if self.C.num_verts == self.C.q + self.C.k:
            self.is_good_leaf_counter +=1
        for r in self.RULES:
            if not r(self.C): return False
        return True

    def search_periodic_circuit(self, trivial_periods=None,
                                compare_random=True, progress=False):
        """
        Search through all (good) circuits and test whether they are peridodic.
        trivial_periods: periods that should be filtered out
        compare_random: use random circuit to detect trivial periods
        progress: display progress bar
        """
        if self.C_random == None: compare_random=False
        C = self.C
        no, trivial, interesting = 0, 0, 0
        if progress:
            progress = tqdm(total=int((self.circuit_tree_size())),
                        unit="circuits")
            last_C = 0
        while True:
            if progress:
                this_C = self.C.to_int()
                progress.update(int(this_C - last_C))
                last_C = this_C
            s = tuple(sorted(C.periods()))
            if s == ():
                no += 1
            elif trivial_periods and s in trivial_periods:
                trivial += 1
            elif compare_random:
                self.C_random.from_int(self.C.to_int())
                s_ = tuple(sorted(self.C_random.periods()))
                if s_:
                    trivial += 1
                else:
                    interesting += 1
                    out = f"Circuit with periods {s}: {C.to_int()}"
                    if progress: tqdm.write(out)
                    else: print(out)
            else:
                interesting += 1
                out = f"Circuit with periods {s}: {C.to_int()}"
                if progress: tqdm.write(out)
                else: print(out)
            flag = self.next_circuit()
            if flag == False:
                # reached final circuit
                break
        if progress:
            progress.update(int((self.circuit_tree_size())))
            progress.close()
        self.print_output(no, trivial, interesting)

    def search_periodic_circuit_gms(self, bits_u, bits_other,
                                    u_=None, compare_random=True,
                                    trivial_periods=None,
                                    progress=False):
        """
        Search through all (good) circuits and test whether they are
        peridodic in the Grover-Meets-Simon case.
        bits_u, bits_other: bit size of first node u, and sum of bit
        sizes of other inputs
        u_: if you only want to check for one u^* else all 2^bits_u
        are checked
        progress: display progress bar
        """
        if self.C_random == None: compare_random=False
        C = self.C
        no, trivial, interesting = 0, 0, 0
        if progress:
            progress = tqdm(total=int((self.circuit_tree_size())),
                            unit="circuits")
            last_C = 0
        while True:
            if progress:
                this_C = self.C.to_int()
                progress.update(int(this_C - last_C))
                last_C = this_C
            U = [u_] if u_ != None else range(2^bits_u)
            for u in U:
                s = tuple(sorted(C.periods_gms(
                    u*2^bits_other, (u+1)*2^bits_other)))
                if s == ():
                    no += 1
                elif trivial_periods and s in trivial_periods:
                    trivial += 1
                elif compare_random:
                    self.C_random.from_int(self.C.to_int())
                    s_ = tuple(sorted(self.C_random.periods_gms(
                        u*2^bits_other, (u+1)*2^bits_other)))
                    if s_:
                        trivial += 1
                    else:
                        interesting += 1
                        o=f"Circuit with periods {s} for u={u}: {C.to_int()}"
                        if progress: tqdm.write(o)
                        else: print(o)
                else:
                    interesting += 1
                    o=f"Circuit with periods {s} for u={u}: {C.to_int()}"
                    if progress: tqdm.write(o)
                    else: print(o)
            flag = self.next_circuit()
            if flag == False:
                # reached final circuit
                break
        if progress:
            progress.update(int((self.circuit_tree_size())))
            progress.close()
        self.print_output(no, trivial, interesting)

    def circuit_tree_size(self):
        return sum(self.circuit_tree_number_of_leaves(k)
                   for k in range(self.C.k+1))

    def circuit_tree_number_of_leaves(self, k=None):
        q = self.C.q
        g = self.C.g
        if k == None: k = self.C.k
        return g^k * rising_factorial(q, k)^2

    def perc(self, A, B, precision=4):
        return f"({100*round((A/B), precision)}%)"

    def print_output(self, no, trivial, interesting):
        perc = self.perc
        T = self.circuit_tree_size()
        L = self.circuit_tree_number_of_leaves()
        print(f"Searched through circuit tree of size {T}")
        print(f"-> {T-L} inner nodes ({perc(T-L, T)})")
        print(f"-> {L} leaves ({perc(L, T)})")

        print(f"Number of circuits tested with rules: ",
              f"{self.is_good_counter} ",
              f"({perc(self.is_good_counter, T)})")
        h1 = self.is_good_counter - self.is_good_leaf_counter
        h2 = perc(self.is_good_counter-self.is_good_leaf_counter,
                  self.is_good_counter)
        h3 = perc(self.is_good_counter-self.is_good_leaf_counter,
                  T-L)
        print(f"-> inner nodes: {h1} ({h3} of inner nodes, ",
              f"{h2} of tests)")
        h1 = self.is_good_leaf_counter
        h2 = perc(self.is_good_leaf_counter, self.is_good_counter)
        h3 = perc(self.is_good_leaf_counter, L)
        print(f"-> leaves: {h1} ({h3}% of leaves, ",
              f"{h2}% of tests)")
        h = perc(self.counter, L)
        print(f"Number of circuits tested for periodicity: ",
              f"{self.counter} ({h}% of leaves)")
        print(f"-> {no} without, {trivial} with trivial and ",
              f"{interesting} with interesting period")
