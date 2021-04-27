% m174.json
% "Billy was buying chips and dip for his party.", "The choices for chips are: Scoop, Square, Triangle and Round.", "The choices for dips are: Salsa, Ranch, Bean and Cheese.", "If he gets one type of chip and one type of dip, how many different combinations can he choose from?"	16

chips = {scoop,square,triangle,round};
dips = {salsa,ranch,bean,cheese};
combination in [| chips+dips];
#combination = 2;
combination[1] = chips;
combination[2] = dips;
