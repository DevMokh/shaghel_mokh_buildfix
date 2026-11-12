class GameData {
  int coins = 500;
  int xp = 0;
  int level = 1;
  String username = 'العبقري المجهول';

  int avatarIcon = 0;
  int avatarColor = 0;
  Set<int> ownedIcons = {0, 1, 2, 3};
  Set<int> ownedColors = {0, 1, 2, 3};

  int hints = 5;
  int skips = 5;
  int deletes = 5;

  int gamesPlayed = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int maxStreak = 0;
  int perfectGames = 0;
  int dailyWins = 0;
  int purchases = 0;
  int totalCoinsEarned = 0;

  int loginStreak = 0;
  int maxLoginStreak = 0;
  String lastLoginDate = '';
  String lastDailyDate = '';

  Set<String> achievements = {};
  Set<String> categoriesPlayed = {};

  GameData();

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'xp': xp,
        'level': level,
        'username': username,
        'avatarIcon': avatarIcon,
        'avatarColor': avatarColor,
        'ownedIcons': ownedIcons.toList(),
        'ownedColors': ownedColors.toList(),
        'hints': hints,
        'skips': skips,
        'deletes': deletes,
        'gamesPlayed': gamesPlayed,
        'correctAnswers': correctAnswers,
        'wrongAnswers': wrongAnswers,
        'maxStreak': maxStreak,
        'perfectGames': perfectGames,
        'dailyWins': dailyWins,
        'purchases': purchases,
        'totalCoinsEarned': totalCoinsEarned,
        'loginStreak': loginStreak,
        'maxLoginStreak': maxLoginStreak,
        'lastLoginDate': lastLoginDate,
        'lastDailyDate': lastDailyDate,
        'achievements': achievements.toList(),
        'categoriesPlayed': categoriesPlayed.toList(),
      };

  factory GameData.fromJson(Map<String, dynamic> j) {
    final d = GameData();
    int n(String k, int def) => (j[k] as num?)?.toInt() ?? def;
    String s(String k, String def) => (j[k] as String?) ?? def;
    d.coins = n('coins', d.coins);
    d.xp = n('xp', d.xp);
    d.level = n('level', d.level);
    d.username = s('username', d.username);
    d.avatarIcon = n('avatarIcon', 0);
    d.avatarColor = n('avatarColor', 0);
    final oi = j['ownedIcons'] as List?;
    if (oi != null) d.ownedIcons = oi.map((e) => (e as num).toInt()).toSet();
    final oc = j['ownedColors'] as List?;
    if (oc != null) d.ownedColors = oc.map((e) => (e as num).toInt()).toSet();
    d.hints = n('hints', d.hints);
    d.skips = n('skips', d.skips);
    d.deletes = n('deletes', d.deletes);
    d.gamesPlayed = n('gamesPlayed', 0);
    d.correctAnswers = n('correctAnswers', 0);
    d.wrongAnswers = n('wrongAnswers', 0);
    d.maxStreak = n('maxStreak', 0);
    d.perfectGames = n('perfectGames', 0);
    d.dailyWins = n('dailyWins', 0);
    d.purchases = n('purchases', 0);
    d.totalCoinsEarned = n('totalCoinsEarned', 0);
    d.loginStreak = n('loginStreak', 0);
    d.maxLoginStreak = n('maxLoginStreak', 0);
    d.lastLoginDate = s('lastLoginDate', '');
    d.lastDailyDate = s('lastDailyDate', '');
    final ach = j['achievements'] as List?;
    if (ach != null) d.achievements = ach.map((e) => e.toString()).toSet();
    final cp = j['categoriesPlayed'] as List?;
    if (cp != null) d.categoriesPlayed = cp.map((e) => e.toString()).toSet();
    return d;
  }
}
