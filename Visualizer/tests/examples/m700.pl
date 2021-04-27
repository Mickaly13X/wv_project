% m700.json
% "An ecology quiz consists of 12 multiple choice questions with four possible answers for each question.", "In how many ways can the quiz be completed?", "Assume that no question is omitted."	495 (?)

questions = [1:12];
answers = {a1,a2,a3,a4};
pair in [| questions+answers];
#pair = 2;
pair[1] = questions;
pair[2] = answers;
