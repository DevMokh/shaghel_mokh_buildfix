import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'achievements_tab.dart';
import 'categories_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'shop_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int i) {
    setState(() {
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      HomeTab(onGoTo: _go),
      const CategoriesTab(),
      const ShopTab(),
      const AchievementsTab(),
      const ProfileTab(),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: IndexedStack(index: _index, children: tabs)),
      bottomNavigationBar: _PillNav(index: _index, onTap: _go),
    );
  }
}

class _PillNav extends StatelessWidget {
  const _PillNav({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.grid_view_rounded,
    Icons.storefront_rounded,
    Icons.emoji_events_rounded,
    Icons.person_rounded,
  ];
  static const List<String> _labels = ['الرئيسية', 'المجالات', 'المتجر', 'الإنجازات', 'حسابي'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.accent.o(0.14)),
          boxShadow: [BoxShadow(color: AppColors.accent.o(0.06), blurRadius: 24)],
        ),
        child: Row(
          children: List.generate(5, (i) {
            final bool sel = i == index;
            final Color c = sel ? AppColors.accent : AppColors.text2;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.accent.o(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_icons[i], color: c, size: 24),
                    ),
                    const SizedBox(height: 2),
                    Text(_labels[i], style: tsx(10, w: sel ? FontWeight.w900 : FontWeight.w700, color: c)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
