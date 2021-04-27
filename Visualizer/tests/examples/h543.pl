% h543.json
% "From 8 soldiers, 7 sailors and 5 airmen how many sets can be formed each containing 5 soldiers, 4 sailors and 3 airmen?"	19600

soldiers = [1:8];
sailors = [9:15];
airmen = [16:20];
set in {| soldiers+sailors+airmen};
#set = 12;
#(soldiers & set) = 5;
#(sailors & set) = 4;
#(airmen & set) = 3;
