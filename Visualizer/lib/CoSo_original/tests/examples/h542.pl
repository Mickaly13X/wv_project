% h542.json
% "In how many ways can a set of 2 boys and 3 girls be selected from 5 boys and 4 girls?"	40

boys = {b1,b2,b3,b4,b5};
girls = {g11,g2,g3,g4};
select in {| boys+girls};
#select = 5;
#(boys & select) = 2;
#(girls & select) = 3;
