import CoSo.src.launcher as launcher
from matplotlib_venn._venn2 import solve_venn2_circles
from matplotlib_venn._venn3 import solve_venn3_circles
from numpy import array
import os
import sys


def coso():
    path_file = os.path.abspath("input_cola.pl")
    print(path_file)
    launcher.launch(path_file)


# venn_size is 2 or 3
def venn(venn_size, *inter_sizes):

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


# system argument 'request_func' must be passed between " " marks
request_func: str = sys.argv[1]
eval(request_func)
