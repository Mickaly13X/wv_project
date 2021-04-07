% m747.json
% "A committee of seven is to be chosen from a group of ten men and eight women.", "In how many ways can the committee be chosen if it must have exactly four men and three women?"	null


men = [1:10];
women = [11:18];
committees in {| men+women};
#committees = 7; 
#(men & committees) = 4;
#(women & committees) = 3;
