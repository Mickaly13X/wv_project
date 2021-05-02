% h545.json
% "A commitees of 7 politicians is chosen from 10 liberal members, 8 labor members and 5 independents.", "In how many ways can this be done so as to include exactly 1 independent and at least 3 liberal members and at least 1 labor member?"	73080

liberals = [1:10];
labors = [11:18];
independents = [19:23];
committee in { | liberals+labors+independents};
#committee = 7;
#(independents & committee) = 1;
#(liberals & committee) >= 3;
#(labors & committee) >= 1;
