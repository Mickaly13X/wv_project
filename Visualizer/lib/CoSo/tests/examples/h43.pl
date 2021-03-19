% h43.json
% "The Acme Plumbing Company will send a team of 3 plumbers to work on a certain job.", "The company has 4 experienced plumbers and 4 trainees.", "If a team consists of 1 experienced plumber and 2 trainees, how many different such teams are possible?"	24

experienced = {e1,e2,e3,e4};
trainees = {t1, t2, t3, t4};
team in {| experienced+trainees};
#team = 3;
#(experienced & team) = 1;
#(trainees & team) = 2;

