% h608.json
% "From a group of 12 people -- 7 of which are men and 5 women -- in how many ways may choose a committee of 4 with 1 man and 3 women?"	70

men = [1:7];
women = [8:12];
committee in {| men+women};
#committee = 4;
#(men & committee) = 1;
#(women & committee) = 3;
