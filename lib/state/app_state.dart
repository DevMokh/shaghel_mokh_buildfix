import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/achievements.dart';
import '../core/constants.dart';
import '../models/game_data.dart';
import '../services/question_repository.dart';

class RoundResult {
  final int correct;
  final int total;
  final int bestStreak;
  final int coins;
  final int xp;
  final int levelsGained;
  final int dailyBonus;
  final bool daily;
  final List<Achievement> newAchievements;
  const RoundResult({
    required this.correct,
    required this.total,
    required this.bestStreak,
    required this.coins,
    required this.xp,
    required this.levelsGained,
    required this.dailyBonus,
    required this.daily,
    required this.newAchievements,
  });
}

class AppState extends ChangeNotifier {
  AppState._(this.repo, this._prefs, this.data);

  final QuestionRepository repo;
  final SharedPreferences _prefs;
  GameData data;
  String? _loginMessage;

  static const String _key = 'game_data_v1';

  static Future<AppState> init() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = await QuestionRepository.load();
    GameData data;
    final raw = prefs.getString(_key);
    if (raw == null) {
      data = GameData();
    } else {
      try {
        data = GameData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        data = GameData();
      }
    }
    final state = AppState._(repo, prefs, data);
    state._updateLoginStreak();
    return state;
  }

  // ───────────── أدوات مساعدة ─────────────
  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get today => _fmt(DateTime.now());
  String get yesterday => _fmt(DateTime.now().subtract(const Duration(days: 1)));

  bool get dailyDone => data.lastDailyDate == today;
  int get xpToNext => xpNeeded(data.level);
  String get rank => rankName(data.level);

  void _save() {
    _prefs.setString(_key, jsonEncode(data.toJson()));
  }

  String? takeLoginMessage() {
    final m = _loginMessage;
    _loginMessage = null;
    return m;
  }

  // ───────────── سلسلة الدخول اليومي ─────────────
  void _updateLoginStreak() {
    if (data.lastLoginDate == today) return;
    if (data.lastLoginDate == yesterday) {
      data.loginStreak += 1;
    } else {
      data.loginStreak = 1;
    }
    if (data.loginStreak > data.maxLoginStreak) {
      data.maxLoginStreak = data.loginStreak;
    }
    data.lastLoginDate = today;
    final days = data.loginStreak > 7 ? 7 : data.loginStreak;
    final reward = 20 * days;
    data.coins += reward;
    data.totalCoinsEarned += reward;
    _loginMessage = 'سلسلة دخول ${data.loginStreak} يوم  +$reward عملة';
    _checkAchievements();
    _save();
  }

  // ───────────── الإنجازات ─────────────
  List<Achievement> _checkAchievements() {
    final unlocked = <Achievement>[];
    for (final a in achievementList) {
      if (!data.achievements.contains(a.id) && a.test(data)) {
        data.achievements.add(a.id);
        data.coins += achievementReward;
        data.totalCoinsEarned += achievementReward;
        unlocked.add(a);
      }
    }
    return unlocked;
  }

  // ───────────── نهاية الجولة ─────────────
  RoundResult completeRound({
    required int correct,
    required int wrong,
    required int total,
    required int bestStreak,
    required int coins,
    required int xp,
    required Set<String> categoriesSeen,
    required bool daily,
  }) {
    data.gamesPlayed += 1;
    data.correctAnswers += correct;
    data.wrongAnswers += wrong;
    if (bestStreak > data.maxStreak) data.maxStreak = bestStreak;
    if (total > 0 && correct == total) data.perfectGames += 1;
    data.categoriesPlayed.addAll(categoriesSeen);

    int earned = coins;
    int bonus = 0;
    if (daily) {
      data.lastDailyDate = today;
      data.dailyWins += 1;
      bonus = 100 + correct * 20;
      earned += bonus;
    }
    data.coins += earned;
    data.totalCoinsEarned += earned;
    data.xp += xp;

    int gained = 0;
    while (data.xp >= xpNeeded(data.level)) {
      data.xp -= xpNeeded(data.level);
      data.level += 1;
      gained += 1;
      final reward = 100 * data.level;
      data.coins += reward;
      data.totalCoinsEarned += reward;
      earned += reward;
    }

    final newOnes = _checkAchievements();
    earned += newOnes.length * achievementReward;

    _save();
    notifyListeners();
    return RoundResult(
      correct: correct,
      total: total,
      bestStreak: bestStreak,
      coins: earned,
      xp: xp,
      levelsGained: gained,
      dailyBonus: bonus,
      daily: daily,
      newAchievements: newOnes,
    );
  }

  // ───────────── المساعدات ─────────────
  int helperCount(String type) {
    switch (type) {
      case 'hint':
        return data.hints;
      case 'skip':
        return data.skips;
      case 'delete':
        return data.deletes;
    }
    return 0;
  }

  bool useHelper(String type) {
    if (helperCount(type) <= 0) return false;
    switch (type) {
      case 'hint':
        data.hints -= 1;
        break;
      case 'skip':
        data.skips -= 1;
        break;
      case 'delete':
        data.deletes -= 1;
        break;
      default:
        return false;
    }
    _save();
    notifyListeners();
    return true;
  }

  void _addHelper(String type, int amount) {
    switch (type) {
      case 'hint':
        data.hints += amount;
        break;
      case 'skip':
        data.skips += amount;
        break;
      case 'delete':
        data.deletes += amount;
        break;
    }
  }

  // ───────────── المتجر ─────────────
  /// يرجّع رسالة خطأ لو فشل الشراء، أو null لو نجح
  String? buyHelper(String type, int amount, int price) {
    if (data.coins < price) return 'رصيدك غير كافٍ';
    data.coins -= price;
    _addHelper(type, amount);
    data.purchases += 1;
    _checkAchievements();
    _save();
    notifyListeners();
    return null;
  }

  String? buyBundle(int each, int price) {
    if (data.coins < price) return 'رصيدك غير كافٍ';
    data.coins -= price;
    _addHelper('hint', each);
    _addHelper('skip', each);
    _addHelper('delete', each);
    data.purchases += 1;
    _checkAchievements();
    _save();
    notifyListeners();
    return null;
  }

  String? selectIcon(int i) {
    if (!data.ownedIcons.contains(i)) {
      final cost = avatarIconCosts[i];
      if (data.coins < cost) return 'رصيدك غير كافٍ';
      data.coins -= cost;
      data.ownedIcons.add(i);
      data.purchases += 1;
      _checkAchievements();
    }
    data.avatarIcon = i;
    _save();
    notifyListeners();
    return null;
  }

  String? selectColor(int i) {
    if (!data.ownedColors.contains(i)) {
      final cost = avatarColorCosts[i];
      if (data.coins < cost) return 'رصيدك غير كافٍ';
      data.coins -= cost;
      data.ownedColors.add(i);
      data.purchases += 1;
      _checkAchievements();
    }
    data.avatarColor = i;
    _save();
    notifyListeners();
    return null;
  }

  // ───────────── الملف الشخصي ─────────────
  String? setUsername(String name) {
    final n = name.trim();
    if (n.length < 3 || n.length > 15) return 'الاسم يجب أن يكون من 3 إلى 15 حرفًا';
    data.username = n;
    _save();
    notifyListeners();
    return null;
  }

  void resetAll() {
    data = GameData();
    _updateLoginStreak();
    _save();
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  /// للاستخدام داخل build (يعيد بناء الواجهة عند أي تغيير)
  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  }

  /// للاستخدام داخل الأحداث (بدون اشتراك في التغييرات)
  static AppState read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
  }
}
