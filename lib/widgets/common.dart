import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class HexPainter extends CustomPainter {
  const HexPainter();

  Path _hex(Size size) {
    final w = size.width / 96;
    final h = size.height / 100;
    return Path()
      ..moveTo(48 * w, 4 * h)
      ..lineTo(90 * w, 27 * h)
      ..lineTo(90 * w, 73 * h)
      ..lineTo(48 * w, 96 * h)
      ..lineTo(6 * w, 73 * h)
      ..lineTo(6 * w, 27 * h)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _hex(size);
    final fill = Paint()..color = AppColors.accent.o(0.15);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..shader = goldGradient.createShader(Offset.zero & size);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    canvas.save();
    canvas.translate(size.width * 0.1, size.height * 0.1);
    canvas.scale(0.8, 0.8);
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.accent.o(0.4);
    canvas.drawPath(path, inner);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// شعار اللعبة: سداسي بتدرج كهرماني + أيقونة المخ
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.04,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.accent.o(0.22), blurRadius: size * 0.45),
              ],
            ),
          ),
          CustomPaint(
            size: Size(size, size * 1.04),
            painter: const HexPainter(),
          ),
          Icon(Icons.psychology, size: size * 0.5, color: AppColors.accent),
        ],
      ),
    );
  }
}

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({
    super.key,
    required this.iconIndex,
    required this.colorIndex,
    this.size = 56,
  });
  final int iconIndex;
  final int colorIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = avatarColors[colorIndex % avatarColors.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [BoxShadow(color: color.o(0.35), blurRadius: size * 0.3)],
      ),
      child: Icon(avatarIcons[iconIndex % avatarIcons.length],
          size: size * 0.5, color: Colors.black.o(0.85)),
    );
  }
}

class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.icon, required this.label, this.color = AppColors.accent});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.o(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.o(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: tsx(13, w: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

class GoldButton extends StatelessWidget {
  const GoldButton({super.key, required this.label, required this.onTap, this.icon, this.enabled = true});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled ? onTap : null,
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              gradient: goldGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.accent.o(0.3), blurRadius: 18, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.black, size: 22),
                  const SizedBox(width: 8),
                ],
                Text(label, style: tsx(17, w: FontWeight.w900, color: Colors.black)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
      child: Row(
        children: [
          Container(width: 3, height: 16, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: tsx(16, w: FontWeight.w900))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

void showSnack(BuildContext context, String message) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
}
