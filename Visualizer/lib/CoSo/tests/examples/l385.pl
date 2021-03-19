% l385.json
% "A child has five balls, all identical except for color.", "One is red, one is blue and three are white.", "Assuming there are five positions in a horizontal row, each of which can hold one ball, how many distinguishable arrangements of the five balls can he possibly make?"	20

indist red = {r};
indist blue = {b};
indist white = {w1,w2,w3};
arrangements in [| red+blue+white];
#arrangements = 5;
