from numpy import array
import sys
from matplotlib_venn._venn2 import solve_venn2_circles
from matplotlib_venn._venn3 import solve_venn3_circles


venn_size = int(sys.argv[1]) # venn_size is 2 or 3
inter_sizes = [int(i) for i in sys.argv[2:]]

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
