% m618.json
% "In how many distinguishable ways can the letters in MITOSIS be written?"	1260

indist ms = {m};
indist is = {i1,i2};
indist ts = {t};
indist o = {o};
indist ss = {s1,s2};
word in [| ms+is+ts+o+ss];
#word = 7;
