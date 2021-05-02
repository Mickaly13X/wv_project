% h729.json
% "From 4 red, 5 green, and 6 yellow apples, how many selections of 9 apples are possible if 3 of each color are to be selected?"	800

red = [1:4];
green = [5:9];
yellow = [10:15];
selection in {| red+green+yellow};
#selection = 9;
#(red & selection) >=3;
#(green & selection) >=3;
#(yellow & selection) >=3;
