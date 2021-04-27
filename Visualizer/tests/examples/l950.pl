% l950.json
% "A machinist produces 22 items during a shift.", "Three of the 22 items are defective and the rest are not defective.", "In how many different orders can the 22 items be arranged if all the defective items are considered identical and all the nondefective items are identical of a different class?"	1540

indist items = [1:19];
indist defective = [20:22];
order in [| items+defective];
#order = 22; 
