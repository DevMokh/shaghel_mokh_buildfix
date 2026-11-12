import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color bg = Color(0xFF050505);
  static const Color card = Color(0xFF0E0E10);
  static const Color card2 = Color(0xFF17171B);
  static const Color accent = Color(0xFFF59E0B);
  static const Color accent2 = Color(0xFFD97706);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color blue = Color(0xFF60A5FA);
  static const Color orange = Color(0xFFF97316);
  static const Color text2 = Color(0x99FFFFFF);
  static const Color border = Color(0x24F59E0B);
}

extension ColorOpacityX on Color {
  /// لون بشفافية معينة (0.0 - 1.0) بدون استخدام withOpacity المهجورة
  Color o(double opacity) => withAlpha((opacity * 255).round());
}

const LinearGradient goldGradient = LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [AppColors.accent, AppColors.accent2],
);

BoxDecoration cardDecoration({double radius = 20, Color? color, Color? border}) {
  return BoxDecoration(
    color: color ?? AppColors.card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border ?? AppColors.border),
  );
}

TextStyle tsx(double size,
    {FontWeight w = FontWeight.w700, Color color = Colors.white, double? height}) {
  return TextStyle(fontSize: size, fontWeight: w, color: color, height: height);
}

ThemeData buildTheme() {
  const ColorScheme scheme = ColorScheme.dark(
    primary: AppColors.accent,
    secondary: AppColors.accent2,
    surface: AppColors.card,
    error: AppColors.red,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Tajawal',
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.card2,
      contentTextStyle: TextStyle(
          fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Colors.white),
    ),
  );
}
