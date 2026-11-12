import 'package:flutter/material.dart';
import '../core/achievements.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final earned = app.data.achievements;
    final int total = achievementList.length;
    final int count = achievementList.where((a) => earned.contains(a.id)).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Row(
          children: [
            Text('الإنجازات', style: tsx(24, w: FontWeight.w900)),
            const Spacer(),
            Text('$count / $total', style: tsx(15, w: FontWeight.w900, color: AppColors.accent)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : count / total,
            minHeight: 8,
            backgroundColor: AppColors.card2,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 4),
        Text('كل إنجاز تفتحه يعطيك 50 عملة', style: tsx(12, color: AppColors.text2)),
        const SizedBox(height: 14),
        for (final a in achievementList)
          Builder(builder: (context) {
            final bool done = earned.contains(a.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: cardDecoration(
                radius: 18,
                color: done ? AppColors.accent.o(0.07) : AppColors.card,
                border: done ? AppColors.accent.o(0.35) : AppColors.border,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: done ? AppColors.accent.o(0.18) : Colors.white.o(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(done ? a.icon : Icons.lock_rounded,
                        color: done ? AppColors.accent : AppColors.text2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title,
                            style: tsx(15, w: FontWeight.w900, color: done ? Colors.white : AppColors.text2)),
                        Text(a.desc, style: tsx(12, color: AppColors.text2)),
                      ],
                    ),
                  ),
                  if (done) const Icon(Icons.check_circle_rounded, color: AppColors.green),
                ],
              ),
            );
          }),
      ],
    );
  }
}
