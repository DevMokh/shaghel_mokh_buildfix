import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class ShopTab extends StatefulWidget {
  const ShopTab({super.key});
  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  int _section = 0;

  void _report(String? err, String ok) {
    showSnack(context, err ?? ok);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final d = app.data;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Row(
          children: [
            Text('المتجر', style: tsx(24, w: FontWeight.w900)),
            const Spacer(),
            StatChip(icon: Icons.monetization_on_rounded, label: '${d.coins}'),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: cardDecoration(radius: 18),
          child: Row(
            children: [
              Expanded(child: _Seg(label: 'مساعدات', icon: Icons.bolt_rounded, selected: _section == 0, onTap: () => setState(() => _section = 0))),
              Expanded(child: _Seg(label: 'الأفاتار', icon: Icons.face_rounded, selected: _section == 1, onTap: () => setState(() => _section = 1))),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_section == 0) ..._helpers(app) else ..._avatars(app),
      ],
    );
  }

  List<Widget> _helpers(AppState app) {
    final d = app.data;
    return [
      Row(
        children: [
          Expanded(child: _Inv(icon: Icons.lightbulb_rounded, label: 'تلميح', n: d.hints)),
          const SizedBox(width: 8),
          Expanded(child: _Inv(icon: Icons.content_cut_rounded, label: 'حذف', n: d.deletes)),
          const SizedBox(width: 8),
          Expanded(child: _Inv(icon: Icons.skip_next_rounded, label: 'تخطّي', n: d.skips)),
        ],
      ),
      const SectionTitle('شراء نوع واحد'),
      _ShopItem(
        icon: Icons.lightbulb_rounded,
        title: '5 تلميحات',
        desc: 'يكشف أول حرف من الإجابة',
        price: 200,
        onBuy: () => _report(app.buyHelper('hint', 5, 200), 'تم شراء 5 تلميحات'),
      ),
      _ShopItem(
        icon: Icons.content_cut_rounded,
        title: '5 حذف إجابتين',
        desc: 'يحذف إجابتين خاطئتين من الأربعة',
        price: 200,
        onBuy: () => _report(app.buyHelper('delete', 5, 200), 'تم شراء 5 حذف'),
      ),
      _ShopItem(
        icon: Icons.skip_next_rounded,
        title: '5 تخطّي',
        desc: 'تخطّى السؤال بدون خسارة',
        price: 200,
        onBuy: () => _report(app.buyHelper('skip', 5, 200), 'تم شراء 5 تخطّي'),
      ),
      const SectionTitle('حزم وفّر أكتر'),
      _ShopItem(
        icon: Icons.inventory_2_rounded,
        title: 'حزمة المساعدات',
        desc: '3 من كل نوع',
        price: 300,
        onBuy: () => _report(app.buyBundle(3, 300), 'تم شراء حزمة المساعدات'),
      ),
      _ShopItem(
        icon: Icons.diamond_rounded,
        title: 'حزمة الخبير',
        desc: '10 من كل نوع',
        price: 800,
        onBuy: () => _report(app.buyBundle(10, 800), 'تم شراء حزمة الخبير'),
      ),
    ];
  }

  List<Widget> _avatars(AppState app) {
    final d = app.data;
    return [
      Center(child: AvatarBadge(iconIndex: d.avatarIcon, colorIndex: d.avatarColor, size: 90)),
      const SectionTitle('الأيقونة'),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          for (var i = 0; i < avatarIcons.length; i++)
            GestureDetector(
              onTap: () => _report(app.selectIcon(i), 'تم اختيار الأيقونة'),
              child: Container(
                decoration: BoxDecoration(
                  color: d.avatarIcon == i ? AppColors.accent.o(0.15) : AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: d.avatarIcon == i ? AppColors.accent : Colors.white.o(0.08),
                    width: d.avatarIcon == i ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(avatarIcons[i], color: d.ownedIcons.contains(i) ? Colors.white : AppColors.text2, size: 26),
                    const SizedBox(height: 4),
                    if (!d.ownedIcons.contains(i))
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_rounded, size: 11, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text('${avatarIconCosts[i]}', style: tsx(10, w: FontWeight.w900, color: AppColors.accent)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
      const SectionTitle('لون الخلفية'),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var i = 0; i < avatarColors.length; i++)
            GestureDetector(
              onTap: () => _report(app.selectColor(i), 'تم اختيار اللون'),
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: avatarColors[i],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: d.avatarColor == i ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: d.ownedColors.contains(i)
                        ? null
                        : Icon(Icons.lock_rounded, size: 18, color: Colors.black.o(0.7)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    d.ownedColors.contains(i) ? ' ' : '${avatarColorCosts[i]}',
                    style: tsx(10, w: FontWeight.w900, color: AppColors.accent),
                  ),
                ],
              ),
            ),
        ],
      ),
    ];
  }
}

class _Seg extends StatelessWidget {
  const _Seg({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          gradient: selected ? goldGradient : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.black : AppColors.text2),
            const SizedBox(width: 6),
            Text(label, style: tsx(14, w: FontWeight.w900, color: selected ? Colors.black : AppColors.text2)),
          ],
        ),
      ),
    );
  }
}

class _Inv extends StatelessWidget {
  const _Inv({required this.icon, required this.label, required this.n});
  final IconData icon;
  final String label;
  final int n;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: cardDecoration(radius: 16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 4),
          Text('$n', style: tsx(18, w: FontWeight.w900)),
          Text(label, style: tsx(11, color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  const _ShopItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.price,
    required this.onBuy,
  });
  final IconData icon;
  final String title;
  final String desc;
  final int price;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: cardDecoration(radius: 18),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: AppColors.accent.o(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tsx(15, w: FontWeight.w900)),
                Text(desc, style: tsx(12, color: AppColors.text2)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onBuy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on_rounded, size: 16, color: Colors.black),
                  const SizedBox(width: 4),
                  Text('$price', style: tsx(14, w: FontWeight.w900, color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
