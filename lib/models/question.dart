class Question {
  final String text;
  final List<String> options;
  final int correct;
  final String explanation;
  final String category;
  final String sub;

  const Question({
    required this.text,
    required this.options,
    required this.correct,
    required this.explanation,
    required this.category,
    required this.sub,
  });

  factory Question.fromJson(Map<String, dynamic> j) {
    return Question(
      text: j['t'].toString(),
      options: (j['a'] as List).map((e) => e.toString()).toList(),
      correct: (j['c'] as num).toInt(),
      explanation: (j['x'] ?? '').toString(),
      category: j['category'].toString(),
      sub: j['subCategory'].toString(),
    );
  }
}
