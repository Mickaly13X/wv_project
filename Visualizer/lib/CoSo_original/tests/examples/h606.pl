% h606.json
% "In this problem you will determine how many different signals, each consisting of 10 flags hung in a line, can be made from a set of 4 white flags, 3 red flags, 2 blue flags, and 1 orange flag, if flags of the same colour are identical.", "How many are there if there are no constraints on the order?"	(10!)/(4!*3!*2!)


indist white = {w1,w2,w3,w4};
indist red = {r1,r2,r3};
indist blue = {b1,b2};
indist orange = {o};
draw in [ | white+red+blue+orange];
#draw = 10;

