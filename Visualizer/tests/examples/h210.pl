% h210.json
% "In how many ways can we arrange in a line, two apples, six pears, three bananas, and two plums?"	13!/(2!6!3!2!)

indist apples = {a1,a2};
indist pears = {p1,p2,p3,p4,p5,p6};
indist bananas = {b1,b2,b3};
indist plums = {pl1, pl2};
line in [| apples+pears+bananas+plums];
#line = 13;
