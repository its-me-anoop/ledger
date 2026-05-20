import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      ),
      icon: const _GoogleLogo(),
      label: Text(
        'Continue with Google',
        style: AppTypography.base(weight: FontWeight.w500),
      ),
    );
  }
}

// SVG-free minimal Google 'G' rendered via CustomPaint.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GPainter()),
    );
  }
}

class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      Color(0xFF4285F4),
      Color(0xFF34A853),
      Color(0xFFFBBC05),
      Color(0xFFEA4335),
    ];
    final paint = Paint()..style = PaintingStyle.fill;
    final r = size.width / 2;
    final cx = r;
    final cy = r;

    // Blue arc (right)
    paint.color = colors[0];
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.5,
      3.3,
      true,
      paint,
    );
    // Overdraw center to make ring
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.6, paint);
  }

  @override
  bool shouldRepaint(_GPainter old) => false;
}
