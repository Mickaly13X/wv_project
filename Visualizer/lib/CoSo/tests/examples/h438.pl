% h438.json
% "Twenty distinct cars park in the same parking lot every day.", "Ten of these cars are US-made, while the other ten are foreign-made.", "The parking lot has exactly twenty spaces, all in a row, so the cars park side by side.", "However, the drivers have varying schedules so the position any car might take on a certain day is random.", "In how many different ways can the cars line up?"	20!

us = [1:10];
foreign = [11:20];
park in [| us+foreign];
#park = 20;
