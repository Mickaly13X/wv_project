% h547.json
% "From 4 oranges, 3 bananas and 2 apples, how many selections of 5 pieces of fruit can be made, talking at least one of each kind?"	98

oranges = {o1,o2,o3,o4};
bananas = {b1,b2,b3};
apples = {a1,a2};
selection in {| oranges+bananas+apples};
#selection = 5;
#(oranges & selection) > 0;
#(bananas & selection) > 0;
#(apples & selection) > 0;
