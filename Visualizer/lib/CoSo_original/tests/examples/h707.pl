% h707.json
% "In how many ways can 3 oaks, 4 pines, and 2 maples be arranged along a property line if one does not distinguish among trees of the same kind?"	1260

indist oaks = {o1,o2,o3};
indist pines = {p1,p2,p3,p4};
indist maples = {m1,m2};
trees in [| maples+pines+oaks];
#trees = 9;
