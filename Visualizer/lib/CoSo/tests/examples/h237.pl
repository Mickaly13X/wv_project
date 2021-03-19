% h237.json
% "A house has 12 rooms.", "We want to paint 4 yellow, 3 purple, and 5 red.", "In how many ways can this be done?"	27,720

indist yellow = {y1,y2,y3,y4};
indist purple = {p1,p2,p3};
indist red = {r1,r2,r3,r4,r5};
rooms in [| yellow+purple+red];
#rooms = 12;
