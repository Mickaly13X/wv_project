include "globals.mzn";
set of int: uni = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
set of int: dom1 = {4,5,6,7,8,9};
set of int: dom2 = {2,3,4,5,6,7,8,9,10,11,12,13,14};
int: n = 10;
var set of uni: sub;
constraint card(sub) == n;
set of int: df1= uni diff dom2;
constraint sum(i in sub)(bool2int(i in df1)) >= 9 /\ sum(i in sub)(bool2int(i in df1)) <= 11;
set of int: df2= uni diff dom1;
set of int: df3= dom2 union df2;
constraint sum(i in sub)(bool2int(i in df3)) >= 0 /\ sum(i in sub)(bool2int(i in df3)) <= 1;
constraint sum(i in sub)(bool2int(i in dom2)) >= 0 /\ sum(i in sub)(bool2int(i in dom2)) <= 4;
solve satisfy;