% m625.json
% "Six people are lining up for a ride on a toboggan, but only two of the six are willing to take the first position.", "With that constraint, in how many ways can the six people be seated on the toboggan?"	15(?)

people = [1:6];
willing = {1,2};
seated in [| people];
#seated = 6;
seated[1] = willing;
