% m617.json
% "In how many distinguishable ways can the letters in B A N A N A be written?"	60

indist bs = {b};
indist as = {a1,a2,a3};
indist ns = {n1,n2};
words in [| bs+as+ns];
#words = 6;
