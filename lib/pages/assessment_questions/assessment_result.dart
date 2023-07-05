int dyslexiaScore = 0;

// class AssessmentResult {
//   static bool assessDyslexia(List<int> answers) {
//     // Check if the number of answers is correct
//     if (answers.length != 7) {
//       throw Exception('Invalid number of answers');
//     }

//     // Calculate the total number of positive (true) answers
//     int positiveAnswers = answers.where((answer) => answer).length;

//     // Determine the threshold for dyslexia based on the number of questions
//     double threshold = 4.0; // Adjust this threshold as needed

//     // Compare the number of positive answers to the threshold
//     return positiveAnswers >= threshold;
//   }
// }