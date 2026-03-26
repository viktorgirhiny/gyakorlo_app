class Question {
  final int id;
  final String question;
  final List<String> answers;
  final String correctAnswer;

  Question({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      question: json['question'] as String,
      answers: List<String>.from(json['answers']),
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}

enum AnswerState { idle, selected, correct, wrong }
