import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';

class QuestionRepository {
  final List<Question> all;
  QuestionRepository(this.all);

  static Future<QuestionRepository> load() async {
    final raw = await rootBundle.loadString('assets/data/questions.json');
    final list = jsonDecode(raw) as List;
    return QuestionRepository(
      list.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  bool _match(Question q, String? category, String? sub) {
    if (category != null && q.category != category) return false;
    if (sub != null && q.sub != sub) return false;
    return true;
  }

  int count({String? category, String? sub}) =>
      all.where((q) => _match(q, category, sub)).length;

  /// جولة عشوائية: لو القسم الفرعي فيه أقل من العدد المطلوب نكمل من المجال كله
  List<Question> round({String? category, String? sub, int count = 10}) {
    var pool = all.where((q) => _match(q, category, sub)).toList();
    if (pool.length < count && category != null) {
      pool = all.where((q) => q.category == category).toList();
    }
    pool.shuffle(Random());
    return pool.take(count).toList();
  }

  /// تحدي اليوم: نفس الأسئلة لكل اللاعبين في نفس اليوم
  List<Question> daily(DateTime d) {
    final seed = d.year * 10000 + d.month * 100 + d.day;
    final list = List<Question>.of(all);
    list.shuffle(Random(seed));
    return list.take(10).toList();
  }
}
