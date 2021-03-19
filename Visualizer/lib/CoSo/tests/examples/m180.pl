% m180.json
% "Paul was buying chips and dip for his party.", "The choices he has are between scoop and round chips and bean and onion dip.", "If he gets one type of chip and one type of dip, how many different combinations can he choose from?"	4

chips = {scoop, round};
dips = {bean, onion};
combinations in [| chips+dips];
#combinations = 2;
combiantions[1] = chips;
combinations[2] = dips;
