% l1034.json
% "A jury consisting of 2 women and 3 men is to be selected from a group of 5 women and 7 men.", "In how many different ways can this be done?"	350

women = [1:5];
men = [6:12];
jury in {| men+women};
#(women & jury) =2;
#(men & jury) =3;
