% h705.json
% "A contractor wishes to build 9 houses, each different in design.", "In how many ways can he place these houses on a street if 6 lots are on one side of the street and 3 lots are on the opposite side?"	362,880

houses = [1:9];
sides in partitions(houses);
#sides =2;
#{#side=6 | side in sides} = 1;
#{#side=3 | side in sides} = 1;
