% l302.json
% "In how many ways can a lady having 10 dresses, 5 pairs of shoes, and 2 hats be dressed?"	100

dresses = [1:10];
shoes = [11:15];
hats = {h1,h2};
outfit in {| dresses+shoes+hats};
#outfit = 3;
#(dresses & outfit) = 1;
#(shoes & outfit) = 1;
#(hats & outfit) = 1;
