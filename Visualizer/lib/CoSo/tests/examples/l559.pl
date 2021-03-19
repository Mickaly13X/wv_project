% l559.json
% "From a group of 4 men and 5 women, how many committees of size 3 are possible with 1 man and 2 women?"	40

men = [1:4];
women = [5:9];
committees in {| men+women};
#committees =3;
#(men & committees) = 1;
#(women & committees) = 2;
