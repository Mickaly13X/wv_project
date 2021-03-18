from coso.launcher import launch
from matplotlib_venn._venn2 import solve_venn2_circles
from matplotlib_venn._venn3 import solve_venn3_circles
from numpy import array
import os
import sys


def coso():
    path_file = os.path.abspath("input_cola.pl")
    launch(path_file)


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


function_name = str
if int(sys.argv[1]) == 0:
    function_name = "venn"
else:
    function_name = "coso"

arguments = []
for i in sys.argv[2:]:
    arguments.append(int(i))
    
request_func = function_name + "(" + str(arguments).strip("[]") + ")"
eval(request_func)
