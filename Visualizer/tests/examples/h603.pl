% h603.json
% "A bookshelf contains 3 Russian novels, 4 German novels, and 5 Spanish novels.", "In how many ways may we align them if there are no constraints as to grouping?"	479001600

russian = {r1,r2,r3};
german = {g1,g2,g3,g4};
spanish = {s1,s2,s3,s4,s5};
align in [| russian+german+spanish];
#align = 12;
