% h140.json
% "A child has 12 blocks, of which 6 are black, 4 are red, 1 is white, and 1 is blue.", "If the child puts the blocks in a line, how many arrangements are possible?"	27,720

indist black = [1:6];
indist red = [7:10];
indist white = {11};
indist blue = {12};
line in [| black+red+blue+white];
#line = 12;
