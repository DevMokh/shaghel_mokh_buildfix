import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _rename(BuildContext context) async {
    final app = AppScope.read(context);
    final String? name = await showDialog<String>(
      context: context,
      builder: (ctx) => _RenameDialog(initial: app.data.username),
    );
    if (name == null || !context.mounted) return;
    final err = app.setUsername(name);
    showSnack(context, err ?? 'تم تغيير الاسم');
  }

  Future<void> _reset(BuildContext context) async {
    final app = AppScope.read(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card2,
        title: Text('مسح كل البيانات؟', style: tsx(18, w: FontWeight.w900)),
        content: Text('هيتم تصفير العملات والمستوى والإنجازات نهائيًا.', style: tsx(14, color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('إلغاء', style: tsx(15, w: FontWeight.w900, color: AppColors.accent)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('امسح', style: tsx(15, w: FontWeight.w900, color: AppColors.red)),
          ),
        ],
      ),
    );
    if (ok == true) app.resetAll();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final d = app.data;
    final int answered = d.correctAnswers + d.wrongAnswers;
    final String accuracy = answered == 0 ? '0%' : '${(d.correctAnswers * 100 / answered).round()}%';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Center(child: AvatarBadge(iconIndex: d.avatarIcon, colorIndex: d.avatarColor, size: 96)),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: () => _rename(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d.username, style: tsx(22, w: FontWeight.w900)),
                const SizedBox(width: 6),
                const Icon(Icons.edit_rounded, size: 18, color: AppColors.accent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text('${app.rank} • المستوى ${d.level}',
              style: tsx(13, w: FontWeight.w800, color: AppColors.accent)),
        ),
        const SectionTitle('الإحصائيات'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: cardDecoration(),
          child: Column(
            children: [
              _Row('جولات ملعوبة', '${d.gamesPlayed}'),
              _Row('إجابات صحيحة', '${d.correctAnswers}'),
              _Row('إجابات خاطئة', '${d.wrongAnswers}'),
              _Row('نسبة الدقة', accuracy),
              _Row('أعلى سلسلة صحيحة', '${d.maxStreak}'),
              _Row('جولات كاملة', '${d.perfectGames}'),
              _Row('تحديات يومية', '${d.dailyWins}'),
              _Row('سلسلة الدخول', '${d.loginStreak} يوم'),
              _Row('إجمالي العملات المكتسبة', '${d.totalCoinsEarned}'),
              _Row('الإنجازات', '${d.achievements.length}', last: true),
            ],
          ),
        ),
        const SectionTitle('حول اللعبة'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration(),
          child: Text(
            'شغل مخك الإصدار الألترا 4.0 — لعبة تريفيا عربية فيها ${app.repo.all.length} سؤال في 12 مجال. بياناتك محفوظة على جهازك.',
            style: tsx(13, color: AppColors.text2, height: 1.6),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _reset(context),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.red.o(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.red.o(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_forever_rounded, color: AppColors.red),
                const SizedBox(width: 8),
                Text('مسح كل البيانات', style: tsx(15, w: FontWeight.w900, color: AppColors.red)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.last = false});
  final String label;
  final String value;
  final bool last;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: Colors.white.o(0.06))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: tsx(14, color: AppColors.text2))),
          Text(value, style: tsx(15, w: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});
  final String initial;
  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card2,
      title: Text('اسمك في اللعبة', style: tsx(18, w: FontWeight.w900)),
      content: TextField(
        controller: _c,
        maxLength: 15,
        autofocus: true,
        style: tsx(16, w: FontWeight.w800),
        decoration: const InputDecoration(hintText: 'من 3 إلى 15 حرفًا'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('إلغاء', style: tsx(15, w: FontWeight.w900, color: AppColors.text2)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_c.text),
          child: Text('حفظ', style: tsx(15, w: FontWeight.w900, color: AppColors.accent)),
        ),
      ],
    );
  }
}
