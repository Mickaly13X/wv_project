% l88.json
% "A restaurant offers 5 choices of appetizer, 10 choices of main meal and 4 choices of dessert.", "A customer can choose to eat just one course, or two different courses, or all three courses.", "Assuming all choices are available, how many different possible meals does the restaurant offer?"	329

appetizers = [1:5];
main = [6:15];
dessert = [16:19];
choices in {| appetizers+main+dessert};
#choices <= 3; 

