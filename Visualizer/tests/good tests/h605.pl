% h605.json
% "An urn has 2 white marbles, 3 red marbles, and 5 blue marbles.", "Marbles are drawn one by one and without replacement.", "Urns of each colour are indistinguishable.", "In how many ways may one draw the marbles out of the urn?"	(10!)/(2!*3!*5!)


indist white = {w1,w2};
indist red = {r1,r2,r3};
indist blue = {b1,b2,b3,b4,b5};
draw in [| white+red+blue];
#draw = 10;
