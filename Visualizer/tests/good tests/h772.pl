% h772.json
% "T'anna is planting 11 colored flowers in a line.", "In how many ways can she plant 4 red flowers, 5 yellow flowers, and 2 purple flowers?"	6930

indist red = {r1,r2,r3,r4};
indist yellow = {y1,y2,y3,y4,y5};
indist purple = {p1,p2};
plant in [| red+yellow+purple];
#plant = 11;
