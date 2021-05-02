% h937.json
% "In how many distinct ways can 10 A 's, 5 B 's, and 2 C 's be awarded to a class of 17 students?"	408408

indist as = [1:10];
indist bs = [11:15];
indist cs = {c1,c2};
award in [| as+bs+cs];
#award = 17; 
