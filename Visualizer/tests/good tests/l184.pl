% l184.json
% "An airline has six flights from New York to California and seven flights from California to Hawaii per day.", "If the flights are to be made on separate days, how many different flight arrangements can the airline offer from New York to Hawaii?"	42

ny = [1:6];
cal = [7:13];
arrange in [| ny+cal];
#arrange = 2;
arrange[1] = ny;
arrange[2] = cal;
