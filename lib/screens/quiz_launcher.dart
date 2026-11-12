import 'package:flutter/material.dart';
import '../models/question.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

Route<void> quizRoute(
  AppState app, {
  String? category,
  String? sub,
  bool daily = false,
  required String title,
}) {
  final List<Question> qs =
      daily ? app.repo.daily(DateTime.now()) : app.repo.round(category: category, sub: sub);
  return MaterialPageRoute<void>(
    // AppScope is provided around HomeShell, which is below MaterialApp's
    // Navigator. A pushed route is not a descendant of that provider, so
    // explicitly provide the same AppState to every quiz route.
    builder: (_) => AppScope(
      state: app,
      child: QuizScreen(
        questions: qs,
        title: title,
        category: category,
        sub: sub,
        daily: daily,
      ),
    ),
  );
}

void launchQuiz(
  BuildContext context, {
  String? category,
  String? sub,
  bool daily = false,
  String? title,
}) {
  final app = AppScope.read(context);
  if (daily && app.dailyDone) {
    showSnack(context, 'أنهيت تحدي اليوم بالفعل، عُد غدًا لتحدٍ جديد');
    return;
  }
  Navigator.of(context).push(
    quizRoute(app, category: category, sub: sub, daily: daily, title: title ?? 'تحدٍ عشوائي'),
  );
}
