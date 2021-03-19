% h612.json
% "From three Russians, four Americans, and two Spaniards, how many selections of people can be made, taking at least one of each kind?"	315

russians = {r1,r2,r3};
americans = {a1,a2,a3,a4};
spaniards = {s1,s2};
selection in {| russians+americans+spaniards};
#(russians & selection) > 0;
#(spaniards & selection) > 0;
#(americans & selection) > 0;
