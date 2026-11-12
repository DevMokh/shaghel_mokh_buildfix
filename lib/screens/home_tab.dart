import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'quiz_launcher.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.onGoTo});
  final ValueChanged<int> onGoTo;
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final msg = AppScope.read(context).takeLoginMessage();
      if (msg != null) showSnack(context, msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final d = app.data;
    final double progress = (d.xp / app.xpToNext).clamp(0.0, 1.0).toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Row(
          children: [
            StatChip(icon: Icons.monetization_on_rounded, label: '${d.coins}'),
            const Spacer(),
            StatChip(icon: Icons.local_fire_department_rounded, label: '${d.loginStreak}', color: AppColors.orange),
            const SizedBox(width: 8),
            StatChip(icon: Icons.emoji_events_rounded, label: 'Lv ${d.level}'),
          ],
        ),
        const SizedBox(height: 22),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AvatarBadge(iconIndex: d.avatarIcon, colorIndex: d.avatarColor, size: 100),
              Positioned(
                bottom: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: goldGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.bg, width: 2),
                  ),
                  child: Text('المستوى ${d.level}', style: tsx(11, w: FontWeight.w900, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: 'شغل ', style: tsx(36, w: FontWeight.w900)),
              TextSpan(text: 'مخك', style: tsx(36, w: FontWeight.w900, color: AppColors.accent)),
            ]),
          ),
        ),
        Center(child: Text('ULTRA EDITION', style: tsx(11, color: AppColors.text2))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  Text(d.username, style: tsx(15, w: FontWeight.w900)),
                  const Spacer(),
                  Text(app.rank, style: tsx(12, w: FontWeight.w900, color: AppColors.accent)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.card2,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text('${d.xp} / ${app.xpToNext} خبرة', style: tsx(11, color: AppColors.text2)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GoldButton(
          label: 'ابدأ التحدي',
          icon: Icons.sports_esports_rounded,
          onTap: () => launchQuiz(context, title: 'تحدٍ عشوائي'),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => launchQuiz(context, daily: true, title: 'تحدي اليوم'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: cardDecoration(
              radius: 20,
              color: app.dailyDone ? AppColors.card : AppColors.accent.o(0.08),
              border: AppColors.accent.o(app.dailyDone ? 0.1 : 0.4),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: AppColors.accent.o(0.15), borderRadius: BorderRadius.circular(14)),
                  child: Icon(
                    app.dailyDone ? Icons.check_circle_rounded : Icons.calendar_month_rounded,
                    color: app.dailyDone ? AppColors.green : AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تحدي اليوم', style: tsx(15, w: FontWeight.w900)),
                      Text(
                        app.dailyDone ? 'أنهيته اليوم، عُد غدًا' : 'نفس الأسئلة لكل اللاعبين + مكافأة إضافية',
                        style: tsx(12, color: AppColors.text2),
                      ),
                    ],
                  ),
                ),
                if (!app.dailyDone) const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.accent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => widget.onGoTo(1),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: cardDecoration(radius: 20, color: AppColors.card2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.grid_view_rounded, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text('اختر مجالًا', style: tsx(15, w: FontWeight.w900)),
              ],
            ),
          ),
        ),
        const SectionTitle('إحصائياتك'),
        Row(
          children: [
            Expanded(child: _Mini(label: 'جولات', value: '${d.gamesPlayed}')),
            const SizedBox(width: 10),
            Expanded(child: _Mini(label: 'إجابات صحيحة', value: '${d.correctAnswers}')),
            const SizedBox(width: 10),
            Expanded(child: _Mini(label: 'أعلى سلسلة', value: '${d.maxStreak}')),
          ],
        ),
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: cardDecoration(radius: 16),
      child: Column(
        children: [
          Text(value, style: tsx(22, w: FontWeight.w900, color: AppColors.accent)),
          const SizedBox(height: 2),
          Text(label, style: tsx(11, color: AppColors.text2)),
        ],
      ),
    );
  }
}
