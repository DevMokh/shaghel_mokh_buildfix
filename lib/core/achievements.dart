import 'package:flutter/material.dart';
import '../models/game_data.dart';

class Achievement {
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  final bool Function(GameData) test;
  const Achievement({
    required this.id,
    required this.title,
    required this.desc,
    required this.icon,
    required this.test,
  });
}

const int achievementReward = 50;

const List<String> egyptLocalCats = [
  'أحياء القاهرة',
  'كلمات مصرية',
  'موسيقى وأغاني',
  'سينما وتليفزيون',
];

final List<Achievement> achievementList = [
  Achievement(
      id: 'first_game',
      title: 'البداية',
      desc: 'أكمل أول جولة لك',
      icon: Icons.flag_rounded,
      test: (d) => d.gamesPlayed >= 1),
  Achievement(
      id: 'games_10',
      title: 'لاعب مثابر',
      desc: 'العب 10 جولات',
      icon: Icons.repeat_rounded,
      test: (d) => d.gamesPlayed >= 10),
  Achievement(
      id: 'games_50',
      title: 'مدمن تريفيا',
      desc: 'العب 50 جولة',
      icon: Icons.local_fire_department_rounded,
      test: (d) => d.gamesPlayed >= 50),
  Achievement(
      id: 'correct_50',
      title: 'عقل متقد',
      desc: 'أجب 50 إجابة صحيحة',
      icon: Icons.lightbulb_rounded,
      test: (d) => d.correctAnswers >= 50),
  Achievement(
      id: 'correct_250',
      title: 'موسوعة متحركة',
      desc: 'أجب 250 إجابة صحيحة',
      icon: Icons.menu_book_rounded,
      test: (d) => d.correctAnswers >= 250),
  Achievement(
      id: 'correct_1000',
      title: 'العبقري',
      desc: 'أجب 1000 إجابة صحيحة',
      icon: Icons.psychology_rounded,
      test: (d) => d.correctAnswers >= 1000),
  Achievement(
      id: 'streak_5',
      title: 'سلسلة نارية',
      desc: 'أجب 5 أسئلة متتالية صحيحة',
      icon: Icons.bolt_rounded,
      test: (d) => d.maxStreak >= 5),
  Achievement(
      id: 'streak_10',
      title: 'لا يُهزم',
      desc: 'أجب 10 أسئلة متتالية صحيحة',
      icon: Icons.whatshot_rounded,
      test: (d) => d.maxStreak >= 10),
  Achievement(
      id: 'perfect_1',
      title: 'جولة كاملة',
      desc: 'أجب كل أسئلة جولة بشكل صحيح',
      icon: Icons.verified_rounded,
      test: (d) => d.perfectGames >= 1),
  Achievement(
      id: 'level_5',
      title: 'مستوى 5',
      desc: 'وصل للمستوى الخامس',
      icon: Icons.trending_up_rounded,
      test: (d) => d.level >= 5),
  Achievement(
      id: 'level_10',
      title: 'مستوى 10',
      desc: 'وصل للمستوى العاشر',
      icon: Icons.military_tech_rounded,
      test: (d) => d.level >= 10),
  Achievement(
      id: 'rich_3000',
      title: 'ثري',
      desc: 'اجمع 3000 عملة',
      icon: Icons.savings_rounded,
      test: (d) => d.coins >= 3000),
  Achievement(
      id: 'daily_1',
      title: 'تحدي اليوم',
      desc: 'أكمل أول تحدي يومي',
      icon: Icons.calendar_month_rounded,
      test: (d) => d.dailyWins >= 1),
  Achievement(
      id: 'daily_7',
      title: 'أسبوع من التحديات',
      desc: 'أكمل 7 تحديات يومية',
      icon: Icons.event_available_rounded,
      test: (d) => d.dailyWins >= 7),
  Achievement(
      id: 'login_7',
      title: 'وفاء',
      desc: 'ادخل اللعبة 7 أيام متتالية',
      icon: Icons.favorite_rounded,
      test: (d) => d.maxLoginStreak >= 7),
  Achievement(
      id: 'shopper',
      title: 'متسوق',
      desc: 'اشترِ أي شيء من المتجر',
      icon: Icons.shopping_bag_rounded,
      test: (d) => d.purchases >= 1),
  Achievement(
      id: 'egypt_native',
      title: 'ابن البلد الأصيل',
      desc: 'العب في كل التصنيفات المصرية المحلية',
      icon: Icons.location_city_rounded,
      test: (d) => egyptLocalCats.every(d.categoriesPlayed.contains)),
  Achievement(
      id: 'all_cats',
      title: 'جوّاب آفاق',
      desc: 'العب في كل التصنيفات الـ 12',
      icon: Icons.public_rounded,
      test: (d) => d.categoriesPlayed.length >= 12),
];
