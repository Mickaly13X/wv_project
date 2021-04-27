% h209.json
% "In how many ways can we arrange in a line: three apples, four pears, and five bananas?"	12!/(3!4!5!)

indist apples = {a1,a2,a3};
indist pears = {p1,p2,p3,p4};
indist bananas = {b1,b2,b3,b4,b5};
line in [| apples+pears+bananas];
#line = 12;
