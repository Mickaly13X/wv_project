% h837.json
% "In an exhibition, 20 cars of the same style that are distinguishable only by their colors, are to be parked in a row, all facing a certain window.", "If four of the cars are blue, three are black, five are yellow, and eight are white, how many choices are there?"	3491888400

indist blue = [1:4];
indist black = [5:7];
indist yellow = [8:12];
indist white = [13:20];
exibition in [| blue+black+yellow+white];
#exibition = 20;
