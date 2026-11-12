import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'quiz_launcher.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.title,
    this.category,
    this.sub,
  });

  final RoundResult result;
  final String title;
  final String? category;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final double pct = r.total == 0 ? 0 : r.correct / r.total;
    final int stars = pct >= 0.8 ? 3 : (pct >= 0.5 ? 2 : (pct > 0 ? 1 : 0));
    final String message = pct >= 1
        ? 'أداء مثالي!'
        : (pct >= 0.8 ? 'ممتاز' : (pct >= 0.5 ? 'جيد جدًا' : 'حاول مرة تانية'));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: i == 1 ? 64 : 48,
                    color: i < stars ? AppColors.accent : AppColors.text2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(child: Text('${r.correct}/${r.total}', style: tsx(54, w: FontWeight.w900, color: AppColors.accent))),
            Center(child: Text(message, style: tsx(20, w: FontWeight.w900))),
            Center(child: Text(title, style: tsx(13, color: AppColors.text2))),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: _Tile(icon: Icons.monetization_on_rounded, label: 'عملات', value: '+${r.coins}')),
                const SizedBox(width: 10),
                Expanded(child: _Tile(icon: Icons.auto_graph_rounded, label: 'خبرة', value: '+${r.xp}')),
                const SizedBox(width: 10),
                Expanded(child: _Tile(icon: Icons.bolt_rounded, label: 'أطول سلسلة', value: '${r.bestStreak}')),
              ],
            ),
            if (r.daily) ...[
              const SizedBox(height: 12),
              _Banner(
                icon: Icons.calendar_month_rounded,
                text: 'مكافأة تحدي اليوم: +${r.dailyBonus} عملة',
                color: AppColors.accent,
              ),
            ],
            if (r.levelsGained > 0) ...[
              const SizedBox(height: 12),
              _Banner(
                icon: Icons.trending_up_rounded,
                text: 'ارتقيت ${r.levelsGained} مستوى! حصلت على مكافأة عملات',
                color: AppColors.green,
              ),
            ],
            if (r.newAchievements.isNotEmpty) ...[
              const SectionTitle('إنجازات جديدة'),
              for (final a in r.newAchievements)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: cardDecoration(radius: 16, color: AppColors.accent.o(0.08)),
                  child: Row(
                    children: [
                      Icon(a.icon, color: AppColors.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, style: tsx(15, w: FontWeight.w900)),
                            Text(a.desc, style: tsx(12, color: AppColors.text2)),
                          ],
                        ),
                      ),
                      Text('+50', style: tsx(13, w: FontWeight.w900, color: AppColors.accent)),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 24),
            if (!r.daily)
              GoldButton(
                label: 'العب مجددًا',
                icon: Icons.replay_rounded,
                onTap: () {
                  final app = AppScope.read(context);
                  Navigator.of(context).pushReplacement(
                    quizRoute(app, category: category, sub: sub, title: title),
                  );
                },
              ),
            if (!r.daily) const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: cardDecoration(radius: 20, color: AppColors.card2),
                child: Text('الرئيسية', style: tsx(16, w: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: cardDecoration(radius: 18),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 6),
          Text(value, style: tsx(18, w: FontWeight.w900)),
          Text(label, style: tsx(11, color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.o(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.o(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: tsx(14, w: FontWeight.w800, color: color))),
        ],
      ),
    );
  }
}
