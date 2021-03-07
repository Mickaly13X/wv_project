% h149.json
% "If there are no restrictions on where the digits and letters are placed, how many 8-place license plates consisting of 5 letters and 3 digits are possible if no repetitions of letters or digits are allowed."	6*26*25*24*23*22*10*9*8

dutch = {s1, s2, s3};
french = {s3, s4};
row in [| dutch + french];
#row = 2;
row[1] = dutch
