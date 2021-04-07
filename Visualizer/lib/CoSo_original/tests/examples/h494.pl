% h494.json
% "In how many ways can 3 red, 4 blue and 5 yellow balls be arranged in a straight line?"	12!/(3!*4!*5!)

indist red = [1:3];
indist blue = [4:7];
indist yellow = [8:12];
line in [| red+blue+yellow];
#line = 12;
