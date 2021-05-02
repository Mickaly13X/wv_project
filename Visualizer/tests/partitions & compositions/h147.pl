% h147.json
% "In how many ways can a man divide 7 gifts among his 3 children if the eldest is to receive 3 gifts and the others 2 each?"	210

gifts = [1:7];
part in partitions(gifts);
#part = 3;
#{#p=3 | p in part} = 1;
#{#p=2 | p in part} = 2;

