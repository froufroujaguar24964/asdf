load("evaluable_circuit.sage")
load("misty.sage")
load("feistel_known.sage")


def misty_5_L_FK_full_key_recovery():
    # prepare 5-round MISTY L-FK
    N = 6
    F, F_inv = random_permutation(2^N, inverseToo=True)
    K = [ZZ.random_element(2^N) for _ in range(5)]
    ENC = misty_L([lambda x, k=k: F(x)^^k for k in K])
    E_L = lambda l, r: ENC(l, r)[0]
    E_R = lambda l, r: ENC(l, r)[1]
    XOR = lambda x,y: x^^y
    F_inv_ = lambda x,y: F_inv(x)
    F_ = lambda x,y: F(x)
    GATES = [XOR, E_L, E_R, F_, F_inv_]
    X = [x for x in range(2^N)]
    a = ZZ.random_element(2^N)
    A = [a for _ in range(2^N)]
    C_init1 = [X, A]
    C_init2 = [X]

    # recover s1
    C1 = EvaluableCircuit(C_init1, GATES, 3)
    C1.add_gate(4, 0, 0) # 2: F^-1(x)
    C1.add_gate(1, 2, 1) # 3: E_L(F^-1(x),a)
    C1.add_gate(0, 0, 3) # 4: E_L(F^-1(x),a)^^x
    s1 = C1.periods()[0] # k_1 ^^ F(a)

    # recover s2
    C2 = EvaluableCircuit(C_init2, GATES, 4)
    C2.add_gate(4, 0, 0) # 1: F^-1(x)
    C2.add_gate(4, 1, 1) # 2: F^-1(F^-1(x))
    C2.add_gate(2, 2, 1) # 3: E_R(F-1^(F^-1(x)),F^-1(x))
    C2.add_gate(0, 0, 3) # 4: x^^E_R(F-1^(F^-1(x)),F^-1(x))
    s2 = C2.periods()[0] # F(k_0) ^^ k_2

    # recover s3
    C3 = EvaluableCircuit(C_init2, GATES, 7)
    C3.add_gate(3, 0, 0) # 1: F(x)
    C3.add_gate(4, 0, 0) # 2: F^-1(x)
    C3.add_gate(4, 2, 2) # 3: F^-1(F^-1(x))
    C3.add_gate(1, 3, 2) # 4: E_L
    C3.add_gate(2, 3, 2) # 5: E_R
    C3.add_gate(0, 4, 5) # 6: E_L ^^ E_R
    C3.add_gate(0, 6, 1) # 7: E_L ^^ E_R ^^ F(x)
    s3 = C3.periods()[0] # k_0 ^^ k_1 ^^ k_2 ^^ F(k_0)

    # compute keys
    k1 = s1 ^^ F(a)
    k0 = k1 ^^ s2 ^^ s3
    k2 = s2 ^^ F(k0)
    h1 = E_L(F_inv(F_inv(k1)), F_inv(k1))
    k3 = h1 ^^ k0 ^^ k2
    h2 = E_R(F_inv(F_inv(k1)), F_inv(k1)) ^^ h1
    k4 = h2 ^^ F(k0 ^^ k2 ^^ F(k0))
    K_ = [k0, k1, k2, k3, k4]
    print("Success!") if K == K_ else print("Fail!", K, K_)
    return

def misty_4_R_FK_first_key_recovery():
    # prepare 4-round MISTY R-FK
    N = 6
    r = 4
    F, F_inv = random_permutation(2^N, inverseToo=True)
    K = [ZZ.random_element(2^N) for _ in range(r)]
    ENC = misty_R([lambda x, k=k: F(x)^^k for k in K])
    E_L = lambda l, r: ENC(l, r)[0]
    E_R = lambda l, r: ENC(l, r)[1]
    XOR = lambda x,y: x^^y
    F_ = lambda x,y: F(x)
    GATES = [XOR, E_L, E_R, F_,]
    X = [x for x in range(2^N)]
    C_init = [X]

    # recover s = k0
    C = EvaluableCircuit(C_init, GATES, 5)
    C.add_gate(3, 0, 0) # 1: F(x)
    C.add_gate(0, 0, 1) # 2: x ^^ F(x)
    C.add_gate(1, 0, 2) # 3: E_L(x, x ^^ F(x))
    C.add_gate(2, 0, 2) # 4: E_R(x, x ^^ F(x))
    C.add_gate(0, 3, 4) # 5: E_L(x, x ^^ F(x)) ^^ E_R(x, x ^^ F(x))
    k0 = C.periods()[0] # k_0
    print("Success!") if k0 == K[0] else print("Fail!", K, k0)
    return

def feistel_FK_4_key_recovery():
    # prepare 4-round Feistel-FK
    N = 6
    r = 4
    X = [x for x in range(2^N)]
    K = [ZZ.random_element(2^N) for _ in range(r)]
    F, F_inv = random_permutation(2^N, inverseToo=True)
    a = [ZZ.random_element(2^N) for _ in range(2)]
    A0 = [a[0] for _ in range(2^N)]
    C_init = [X, A0]
    P = [lambda x, k=k: F(x)^^k for k in K]
    Enc = Feistel(P)
    E_L = lambda l, r: Enc(l, r)[0]
    E_R = lambda l, r: Enc(l, r)[1]
    XOR = lambda x,y: x^^y
    F_ = lambda x,y: F(x)
    F_inv_ = lambda x,y: F_inv(x)
    GATES = [XOR, E_L, E_R, F_]

    # recover s
    C = EvaluableCircuit(C_init, GATES, 6)
    C.add_gate(1, 0, 1) # 2 E_L(x, a[0])
    C.add_gate(2, 0, 1) # 3 E_R(x, a[0])
    C.add_gate(3, 0, 0) # 4 F(x)
    C.add_gate(0, 3, 4) # 5 E_R(x, a[0]) ^^ F(x)
    C.add_gate(3, 2, 2) # 6 F(E_L(x, a[0]))
    C.add_gate(0, 5, 6) # 7 F(E_L(x, a[0])) ^^ E_R(x, a[0]) ^^ F(x)
    s = C.periods()[0] # => s = K[0]^^F(a[0])

    # compute k0
    k0 = s ^^ F(a[0])
    print("Success!") if k0 == K[0] else print("Fail!")
    return


def feistel_FK_5_key_recovery():
    # prepare 5-round Feistel-FK
    # assumption: F is a permutation
    N = 6
    r = 5
    X = [x for x in range(2^N)]
    K = [ZZ.random_element(2^N) for _ in range(r)]
    F, F_inv = random_permutation(2^N, inverseToo=True)
    a = [ZZ.random_element(2^N) for _ in range(2)]
    A0 = [a[0] for _ in range(2^N)]
    P = [lambda x, k=k: F(x)^^k for k in K]
    Enc = Feistel(P)
    E_L = lambda l, r: Enc(l, r)[0]
    E_R = lambda l, r: Enc(l, r)[1]
    XOR = lambda x,y: x^^y
    F_ = lambda x,y: F(x)
    F_inv_ = lambda x,y: F_inv(x)
    GATES = [XOR, E_L, E_R, F_]
    C_init = [X]

    # recover s1
    C = EvaluableCircuit(C_init, GATES, 6)
    C.add_gate(3, 0, 0) # 1 F(x)
    C.add_gate(1, 1, 0) # 2 E_L(F(x), x)
    C.add_gate(2, 1, 0) # 3 E_R(F(x), x)
    C.add_gate(0, 1, 3) # 4 F(x) ^^ E_R(F(x), x)
    C.add_gate(3, 2, 2) # 5 F(E_L(F(x), x))
    C.add_gate(0, 4, 5) # 6 F(x) ^^ E_R(F(x), x) ^^ F(E_L(F(x), x))
    s1 = C.periods()[0] # => s = K[1]^^F(K[0])

    # recover s2
    A0 = [K[1] ^^ F(K[0]) for _ in range(2^N)]
    C_init = [X, A0]
    GATES = [XOR, E_L, E_R, F_, F_inv_]
    C = EvaluableCircuit(C_init, GATES, 7)
    # Assumption: F permutation
    C.add_gate(3, 0, 0) # 2 F(x)
    C.add_gate(4, 0, 0) # 3 F_inv(x)
    C.add_gate(0, 1, 3) # 4 F_inv(x) ^^ s
    C.add_gate(3, 4, 4) # 5 F(F_inv(x) ^^ s)
    C.add_gate(1, 5, 4) # 6 E_L(F(F_inv(x) ^^ s), F_inv(x) ^^ s)
    # 7 E_L(F(F_inv(x) ^^ s), F_inv(x) ^^ s) ^^ F(x):
    C.add_gate(0, 2, 6)
    # 8 E_L(F(F_inv(x) ^^ s), F_inv(x) ^^ s) ^^ F(x) ^^ F_inv(x):
    C.add_gate(0, 3, 7)
    s2 = C.periods()[0] # => s2 = K[0]^^K[2] => K[4]

    # compute k4
    k4 = E_R(F(s1), s1) ^^ F(E_L(F(s1), s1)) ^^ F(0) ^^ s2
    print("Success!") if k4 == K[4] else print("Fail!")
    return


print("Verifying attack on 5-round MISTY L-FK:")
misty_5_L_FK_full_key_recovery()
print("Verifying attack on 4-round MISTY R-FK:")
misty_4_R_FK_first_key_recovery()
print("Verifying attack on 4-round Feistel-FK:")
feistel_FK_4_key_recovery()
print("Verifying attack on 5-round Feistel-FK:")
feistel_FK_5_key_recovery()
