% h302.json
% "In a flower shop, there are 5 different types of flowers.", "Two of the flowers are blue, two are red and one is yellow.", "In how many different combinations of different colors can a 3-flower garland be made?"	4


blue = {b1, b2};
red = {r1,r2};
yellow = {y};
garland in {| blue+red+yellow};
#garland = 3;
#(blue & garland) = 1;
#(red & garland) = 1;
#(yellow & garland) = 1;
