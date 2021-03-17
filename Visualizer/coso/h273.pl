% h273.json
% "Suppose you have six different types of flowers and three planters.", "In how many ways can you put three flowers in the first planter, two flowers in the second planter, and one flower in the final planter?"	60

flowers = {t1,t2,t3,t4,t5,t6};
planters in partitions(flowers);
#planters = 3;
#{#p=3 | p in planters} =1;
#{#p=2 | p in planters} =1;
#{#p=1 | p in planters} =1;
