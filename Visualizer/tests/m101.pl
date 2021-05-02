% m101.json
% "In how many ways can we paint 4 houses using 3 colors?"	null

houses = [1:4];
colors = {c1,c2,c3};
pairs in [| houses+colors];
#pairs = 2;
pairs[1] = houses;
pairs[2] = colors;
