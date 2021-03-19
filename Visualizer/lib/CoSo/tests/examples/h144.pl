% h144.json
% "Ten weight lifters are competing in a team weightlifting contest.", "Of the lifters, 3 are from the United States, 4 are from Russia, 2 are from China, and 1 is from Canada.", "If the scoring takes account of the countries that the lifters represent, but not their individual identities, how many different outcomes are possible from the point of view of scores?"	12,600

indist usa = [1:3];
indist russia = [4:7];
indist china = {8,9};
indist canada = {10};
score in [| usa+russia+china+canada];
#score = 10;
