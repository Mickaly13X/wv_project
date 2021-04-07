% l1017.json
% "If a travel agency offers special weekend trips to 12 different cities, by air, rail, bus, or sea, in how many different ways can such a trip be arranged?"	48

means = {air,rail,bus,sea};
city = [1:12];
arranged in [ | means];
#arranged = 2;
arranged[1] = means;
arranged[2] = city;
