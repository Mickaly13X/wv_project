% h491.json
% "From a group of 5 men and 6 women, how many committees of size 3 are possible with 1 man and 2 women?"	C(5,1)*C(6,2)



men = [1:5];
women = [6:11];
committee in {| men+women};
#committee = 3;
#(men & committee) = 1;
#(women & committee) = 2;
