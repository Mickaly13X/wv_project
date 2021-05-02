% m748.json
% "A committee of seven is to be chosen from a group of ten men and eight women.", "In how many ways can the committee be chosen if at least five women must serve in it?"	null


men = [1:10];
women = [11:18];
committees in {| men+women};
#committees = 7; 
#(women & committees) >=5;
