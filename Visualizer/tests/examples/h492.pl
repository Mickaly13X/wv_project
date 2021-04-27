% h492.json
% "A carton of 12 eggs contains 2 spoiled eggs.", "In how many ways can a person choose 3 eggs and get neither of the spoiled eggs?"	C(10,3)

carton = [1:12];
spoiled = {1,2};
choose in {| carton};
#choose = 3;
#(spoiled & choose) = 0;
