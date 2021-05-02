% m726.json
% "A group of 25 campers contains 15 women and 10 men.", "In how many ways can a scouting party of 5 be chosen if it must consist of 3 women and 2 men?"	20475

women = [1:15];
men = [16:25];
parties in {| men +women};
#parties = 5;
#(men & parties) = 2;
#(women & parties) = 3;
