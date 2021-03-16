% h149.json
% "If there are no restrictions on where the digits and letters are placed, how many 8-place license plates consisting of 5 letters and 3 digits are possible if no repetitions of letters or digits are allowed."	6*26*25*24*23*22*10*9*8

letters = {a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z};
digits = [0:9];
plate in [| letters+digits];
#plate = 8;
#(letters & plate) = 5;
#(digits & plate) = 3;
