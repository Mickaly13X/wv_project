% m334.json
% "A student organization has 8 freshman members, 5 sophomores, 10 juniors, and 6 seniors.", "In how many ways can an eight member committee be chosen if there must be two members from each class?"	189000

freshmen = [1:8];
sophomores = [9:13];
juniors = [14:23];
seniors = [24:29];
committee in {| freshmen+sophomores+juniors+seniors};
#committee = 8;
#(freshmen & committee) = 2;
#(sophomores & committee) = 2;
#(juniors & committee) = 2;
#(seniors & committee) = 2;
