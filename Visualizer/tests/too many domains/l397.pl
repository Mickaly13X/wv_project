% l397.json
% "Suppose a box contains 4 blue, 5 white, 6 red and 7 green balls.", "In how many of all possible samples of size 5, chosen without replacement, will every color be represented?"	7560

indist blue = {b1,b2,b3,b4};
indist white = {w1,w2,w3,w4,w5};
indist red = {r1,r2,r3,r4,r5,r6};
indist green = {g1,g2,g3,g4,g5,g6,g7};
samples in [| blue+white+red+green];
#samples = 5; 
#(blue & samples) > 0;
#(white & samples) > 0;
#(red & samples) > 0;
#(green & samples) > 0;
