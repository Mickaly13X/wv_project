% m178.json
% "Emily was trying to decide which salad to order for lunch.", "There were 2 types of salad and 3 dressings.", "If each salad comes with 1 dressing, how many different combinations does she have to choose from?"	6

salads = {s1,s2};
dressings = {d1,d2,d3};
combinations in [| salads+dressings];
#combinations = 2;
combinations[1] = salads;
combinations[2] = dressings;
