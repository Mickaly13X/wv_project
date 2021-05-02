% h838.json
% "At various yard sales, a woman has acquired five forks, of which no two are alike.", "The same applies to her four knives and seven spoons.", "In how many different ways can three place settings be chosen if each place setting consists of exactly one fork, one knife, and one spoon?"	50400

forks = {f1,f2,f3,f4,f5};
knives = {k1,k2,k3,k4};
spoons = {s1,s2,s3,s4,s5,s6,s7};
setting in [| forks+knives+spoons];
#setting = 3;
#(forks & setting) = 1;
#(spoons & setting) = 1;
#(knives & setting) = 1;
