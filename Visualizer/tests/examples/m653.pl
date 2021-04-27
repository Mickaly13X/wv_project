% m653.json
% "An employer interviews 10 people for four openings at a company.", "Four of the 10 people are women.", "All 10 applicants are qualified.", "In how many ways can the employer fill the four positions, given that exactly 2 selections are women?"	null


people = [1:10];
women = [1:4];
positions in {| people};
#positions = 4;
#(women & positions) = 2;
