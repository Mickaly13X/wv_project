% m624.json
% "In a physiology class, a student must dissect three different organisms.", "The student can select one of nine earthworms, one of four frogs, and one of seven fetal pigs.", "In how many ways can the student select the specimens?"	1140

earthworms = [1:9];
frogs = {f1,f2,f3,f4};
pigs = [10:16];
organisms in {| earthworms+frogs+pigs};
#organisms = 3;
