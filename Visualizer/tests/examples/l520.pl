% l520.json
% "In how many ways can 7 graduate students be assigned to one triple and two double hotel rooms during a conference?"	210

students = [1:7];
rooms in partitions(students);
#rooms = 3;
#{#room=3 | room in rooms} = 1;
#{#room=2 | room in rooms} = 2;
