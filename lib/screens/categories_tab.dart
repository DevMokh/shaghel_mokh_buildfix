import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import 'quiz_launcher.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  void _openSubs(BuildContext context, CategoryInfo c) {
    final app = AppScope.read(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.white.o(0.15), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: c.color.o(0.15), borderRadius: BorderRadius.circular(14)),
                    child: Icon(c.icon, color: c.color),
                  ),
                  const SizedBox(width: 10),
                  Text(c.name, style: tsx(20, w: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 14),
              for (final s in c.subs)
                _SubRow(
                  name: s,
                  count: app.repo.count(category: c.name, sub: s),
                  color: c.color,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    launchQuiz(context, category: c.name, sub: s, title: '${c.name} • $s');
                  },
                ),
              _SubRow(
                name: 'كل أقسام المجال',
                count: app.repo.count(category: c.name),
                color: AppColors.accent,
                onTap: () {
                  Navigator.of(ctx).pop();
                  launchQuiz(context, category: c.name, title: c.name);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Text('المجالات', style: tsx(24, w: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('اختر مجالًا وقسمًا فرعيًا وابدأ جولة من 10 أسئلة', style: tsx(12, color: AppColors.text2)),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            for (final c in categories)
              GestureDetector(
                onTap: () => _openSubs(context, c),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: cardDecoration(radius: 22, border: c.color.o(0.25)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: c.color.o(0.15),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(c.icon, color: c.color, size: 28),
                      ),
                      const SizedBox(height: 10),
                      Text(c.name, textAlign: TextAlign.center, style: tsx(15, w: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text('${app.repo.count(category: c.name)} سؤال', style: tsx(11, color: AppColors.text2)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SubRow extends StatelessWidget {
  const _SubRow({required this.name, required this.count, required this.color, required this.onTap});
  final String name;
  final int count;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: cardDecoration(radius: 16, color: AppColors.card2, border: color.o(0.2)),
        child: Row(
          children: [
            Expanded(child: Text(name, style: tsx(15, w: FontWeight.w800))),
            Text('$count', style: tsx(12, color: AppColors.text2)),
            const SizedBox(width: 8),
            Icon(Icons.play_circle_fill_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
