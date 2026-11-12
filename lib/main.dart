import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/firebase_bootstrap.dart';
import 'core/theme.dart';
import 'screens/home_shell.dart';
import 'state/app_state.dart';
import 'widgets/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ShaghelMokhApp());
}

class ShaghelMokhApp extends StatelessWidget {
  const ShaghelMokhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'شغل مخك',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox()),
      home: const _Bootstrap(),
    );
  }
}

/// شاشة التحميل: تحمّل الأسئلة والبيانات المحفوظة ثم تفتح اللعبة
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late final Future<AppState> _future = _load();

  Future<AppState> _load() async {
    final results = await Future.wait<dynamic>([
      AppState.init(),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);
    return results[0] as AppState;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasData) {
          return AppScope(state: snap.data!, child: const HomeShell());
        }
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('حصل خطأ في التحميل:\n${snap.error}',
                    textAlign: TextAlign.center, style: tsx(14, color: AppColors.red)),
              ),
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 110),
                const SizedBox(height: 18),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'شغل ', style: tsx(30, w: FontWeight.w900)),
                      TextSpan(text: 'مخك', style: tsx(30, w: FontWeight.w900, color: AppColors.accent)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('ULTRA EDITION', style: tsx(11, w: FontWeight.w700, color: AppColors.text2)),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}