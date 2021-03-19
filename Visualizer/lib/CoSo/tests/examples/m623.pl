% m623.json
% "A small college needs two additional faculty members: a chemist and a statistician.", "There are five applicants for the chemistry position and six applicants for the statistics position.", "In how many ways can these positions be filled?"	30

chemists = [1:5];
statisticians = [6:11];
additional in [| chemists+statisticians];
#additional = 2;
additional[1] = chemists;
additional[2] = statisticians;
