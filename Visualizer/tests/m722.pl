% m722.json
% "Fourteen construction workers are to be assigned to three different tasks.", "Seven workers are needed for mixing cement, five for laying bricks, and two for carrying the bricks to the brick layers.", "In how many different ways can the workers be assigned to these tasks?"	72072

workers = [1:14];
assignments in partitions(workers);
#assignments=3;
#{#task=7 | task in assignments} = 1;
#{#task=5 | task in assignments} = 1;
#{#task=2 | task in assignments} = 1;
