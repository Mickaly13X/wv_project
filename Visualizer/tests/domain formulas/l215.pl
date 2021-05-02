% l215.json
% "In how many ways can a committee of 4 be formed from 10 men and 12 women if it is to have 2 men and 2 women?"	2970

men = [1:10];
women = [11:22];
committee in {| men+women};
#committee = 4;
#(men & committee) = 2;
#(women & committee) = 2;
