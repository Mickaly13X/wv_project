import sys
import CoSo.src.launcher as launcher
from matplotlib_venn._venn2 import solve_venn2_circles
from matplotlib_venn._venn3 import solve_venn3_circles


def coso():
    launcher.launch("input.pl")


def venn(venn_size: int, inter_sizes):

    c = []
    r = []

    if venn_size == 2:
        c, r = solve_venn2_circles(list(inter_sizes))
    elif venn_size == 3:
        c, r = solve_venn3_circles(list(inter_sizes))

    for i in range(len(c)):
        print(c[i][0]) # x-coordinate
        print(c[i][1]) # y-coordinate
        print(r[i]) # radius


if __name__ == "__main__":

    if sys.argv[1] == 'v':
        venn_size = int(sys.argv[2]) # venn_size is 2 or 3
        inter_sizes = [int(i) for i in sys.argv[3:]]
        venn(venn_size, inter_sizes)
    elif sys.argv[1] == 'c':
        coso()
