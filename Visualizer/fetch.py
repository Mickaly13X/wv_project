from matplotlib_venn._venn2 import solve_venn2_circles
from matplotlib_venn._venn3 import solve_venn3_circles
from numpy import array
import sys

venn_size = int(sys.argv[1]) # 2 or 3

c = []
r = []
if venn_size == 2:
    c, r = solve_venn2_circles([sys.argv[i] for i in range(2, 5)])
elif venn_size == 3:
    c, r = solve_venn3_circles([sys.argv[i] for i in range(2, 9)])

for i in len(range(c)):
    print(c[i][0]) # x-coordinate
    print(c[i][1]) # y-coordinate
    print(r[i]) # radius
