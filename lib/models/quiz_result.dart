class QuizResult {
  final int? id;
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final DateTime completedAt;
  final String difficulty;

  QuizResult({
    this.id,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.completedAt,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'score': score,
      'completedAt': completedAt.toIso8601String(),
      'difficulty': difficulty,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'],
      totalQuestions: map['totalQuestions'],
      correctAnswers: map['correctAnswers'],
      score: map['score'],
      completedAt: DateTime.parse(map['completedAt']),
      difficulty: map['difficulty'],
    );
  }

  QuizResult copyWith({
    int? id,
    int? totalQuestions,
    int? correctAnswers,
    int? score,
    DateTime? completedAt,
    String? difficulty,
  }) {
    return QuizResult(
      id: id ?? this.id,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      score: score ?? this.score,
      completedAt: completedAt ?? this.completedAt,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
