% h611.json
% "A box contains 4 red, 5 white, 6 blue, and 7 magenta balls.", "In how many of all possible samples of size 5, chosen without replacement, will every colour be represented?"	7560

white = {w1,w2,w3,w4,w5};
red = {r1,r2,r3,r4};
blue = {b1,b2,b3,b4,b5,b6};
magenta = {m1,m2,m3,m4,m5,m6,m7};
draw in {| white+red+blue+magenta};
#draw = 5;
#(white & draw)>0;
#(red & draw)>0;
#(blue & draw)>0;
#(magenta & draw)>0;

