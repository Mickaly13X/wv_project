% h290.json
% "In a workshop there are 4 kinds of beds, 3 kinds of closets, 2 kinds of shelves and 7 kinds of chairs.", "In how many ways can a person decorate his room if he wants to buy in the workshop one shelf, one bed and one of the following: a chair or a closet?"	80


beds = {b1,b2,b3,b4};
closets = {c1,c2,c3};
shelves = {s1,s2};
chairs = [1:7];
decoration in {| beds+closets+shelves+chairs};
#decoration = 3;
#(shelves & decoration) = 1;
#(beds & decoration) = 1;
#((chairs+closets) & decoration) = 1;
