% h548.json
% "In how many ways can a jury of 12 be chosen from 10 men and 7 women so that there are at least 6 men and not more than 4 women on each jury"	1946

men = [1:10];
women = [11:17];
jury in {| men+women};
#jury = 12;
#(men & jury) >= 6;
#(women & jury) <=4;
