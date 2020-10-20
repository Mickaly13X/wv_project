from matplotlib_venn._venn2 import solve_venn2_circles
from matplotlib_venn._venn3 import solve_venn3_circles
import sys

venn_size = int(sys.argv[1]) # 2 or 3
venn_areas = list(sys.argv[2])

if venn_size == 2:
    print(solve_venn2_circles(venn_areas))
elif venn_size == 3:
    print(solve_venn3_circles(venn_areas))
