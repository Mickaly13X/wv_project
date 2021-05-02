% l561.json
% "From 4 red, 5 green, and 6 yellow apples, how many selections of 9 apples are possible if 3 of each color are to be selected?"	800

red = [1:4];
green = [5:9];
yellow = [10:15];
selections in {| red+greeen+yellow};
#selections = 9;
#(red & selections) >= 3;
#(green & selections) >= 3;
#(yellow & selections) >= 3;  
