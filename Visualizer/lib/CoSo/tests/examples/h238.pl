% h238.json
% "There are 37 students in a class.", "In how many ways can a professor give out 9 A 's, 13 B 's, 12 C 's, and 5 F 's?"	37!/(9!13!12!5!)

indist a = [1:9];
indist b = [10:22];
indist c = [23:34];
indist f = [35:39];

marks in [| a+b+c+f];
#marks = 37;
