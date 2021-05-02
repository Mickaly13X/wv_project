% h704.json
% "In a fuel economy study, each of 3 race cars is tested using 5 different brands of gasoline at 7 test sites located in different regions of the country.", "If 2 drivers are used in the study, and test runs are made once under each distinct set of conditions, how many tost, runs are needed?"	210

cars = {c1,c2,c3};
brands = [1:5];
sites = [6:12];
drivers = {d1,d2};
conditions in [| cars+brands+sites+drivers];
#conditions = 4;
conditions[1] = cars;
conditions[2] = brands;
conditions[3] = sites;
conditions[4] = drivers;
