% h839.json
% "A dancing contest has 11 competitors, of whom three are Americans, two are Mexicans, three are Russians, and three are Italians.", "If the contest result lists only the nationality of the dancers, how many outcomes are possible?"	92400

indist americans = {a1,a2,a3};
indist mexicans = {m1,m2};
indist russians = {r1,r2,r3};
indist italians = {i1,i2,i3};
contest in [| americans+mexicans+russians+italians];
#contest = 11;
