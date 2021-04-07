% l393.json
% "The Mathematics Department of the University of Louisville consists of 8 professors, 6 associate professors, 13 assistant professors.", "In how many of all possible samples of size 4, chosen without replacement, will every type of professor be represented?"	7488

professors = [1:8];
associates = [9:14];
assistants = [15:27];
samples in {| professors+associates+assistants};
#samples = 4;
#(professors & samples) >= 1;
#(associates & samples) >= 1;
#(assistants & samples) >= 1;

