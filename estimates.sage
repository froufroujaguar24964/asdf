load("circuit.sage")

def all_circuits(q, g, k):
    return g^k * rising_factorial(q, k)^2

def estimate_normal(q, g, k, REP = 2^15):
    A = all_circuits(q, g, k)
    normal = 0
    C = Circuit(q, g, k)
    for _ in range(REP):
        C.random_circuit()
        if C.is_normal():
            normal += 1
    return A*(normal/REP)

def generate_estimate_plot(kmax):
    X = list(range(1,kmax+1))
    p = Graphics()
    VALUES = [[3, 5, "black"], [3, 3, "blue"], [1, 3, "green"]]
    C, C_ = r"\mathscr{C}", r"\mathscr{C}_{norm}"
    for q, g, c in VALUES:
        ALL = list(map(lambda x: all_circuits(q, g, x), X))
        NORMAL = list(map(lambda x: estimate_normal(q, g, x), X))
        p += list_plot_semilogy(list(zip(X, ALL)), base=2,
                plotjoined=True, color=c,
                legend_label=f"$|{C}({q}, {g}, k)$|")
        p += list_plot_semilogy(list(zip(X, NORMAL)), base=2,
                plotjoined=True, color=c, linestyle=":",
                legend_label=f"$|{C_}({q}, {g}, k)|$")
    p.axes_labels(["$k$", ""])
    p.set_legend_options(handlelength=3)
    path = "../tex/data/graphics_generated/"
    fn = path + f"number_of_circuits_{kmax}.pdf"
    p.save(fn, title="", ticks=[1, [2^i for i in range(5, 41, 5)]])

def generate_practice_plot():
    X = list(range(1,7))
    p = Graphics()
    # 4-round Feistel
    T = [46, 3646, 453646, 81453646, 19926453646, 6370326453646]
    RULES = [44, 683, 17307, 345626, 5197925, 63342409]
    PERIOD = [4, 96, 1060, 9006, 62961, 357512]
    c = "black"
    p += list_plot_semilogy(list(zip(X, T)), base=2,
                        plotjoined=True, color=c,
                        legend_label=f"4-Round Feistel: $|T|$")
    p += list_plot_semilogy(list(zip(X, RULES)), base=2,
                        plotjoined=True, color=c, linestyle="--",
                        legend_label=f"4-Round Feistel: Rule Tests")
    p += list_plot_semilogy(list(zip(X, PERIOD)), base=2,
                        plotjoined=True, color=c, linestyle=":",
                        legend_label="4-Round Feistel: Period Tests")
    # 3-round Feistel
    T = [28, 1324, 98524, 10596124, 1553743324, 297838005724]
    RULES = [26, 409, 4683, 40106, 265354, 1351398]
    PERIOD = [4, 32, 156, 510, 973, 1634]
    c = "blue"
    p += list_plot_semilogy(list(zip(X, T)), base=2,
                        plotjoined=True, color=c,
                        legend_label=f"3-Round Feistel: $|T|$")
    p += list_plot_semilogy(list(zip(X, RULES)), base=2,
                        plotjoined=True, color=c, linestyle="--",
                        legend_label=f"3-Round Feistel: Rule Tests")
    p += list_plot_semilogy(list(zip(X, PERIOD)), base=2,
                        plotjoined=True, color=c, linestyle=":",
                        legend_label="3-Round Feistel: Period Tests")
    # EM
    T = [4, 40, 1012, 47668, 3546868, 381460468]
    RULES = [2, 25, 213, 1796, 16795, 168702]
    PERIOD = [1, 4, 17, 86, 479, 3198]
    c = "green"
    p += list_plot_semilogy(list(zip(X, T)), base=2,
                        plotjoined=True, color=c,
                        legend_label=f"Even-Mansour: $|T|$")
    p += list_plot_semilogy(list(zip(X, RULES)), base=2,
                        plotjoined=True, color=c, linestyle="--",
                        legend_label=f"Even-Mansour R: Rule Tests")
    p += list_plot_semilogy(list(zip(X, PERIOD)), base=2,
                        plotjoined=True, color=c, linestyle=":",
                        legend_label="Even-Mansour P: Period Tests")
    p.axes_labels(["$k$", ""])
    p.set_legend_options(handlelength=3)
    fn = "../tex/data/graphics_generated/numbers_in_practice.pdf"
    p.save(fn, title="", ticks=[1, [2^i for i in range(5, 41, 5)]])










