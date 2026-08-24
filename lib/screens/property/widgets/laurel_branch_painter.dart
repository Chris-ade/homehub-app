import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Custom painter for the Laurel Wreath Branches
class LaurelBranchPainter extends CustomPainter {
  final bool isLeft;
  final bool isDark;
  final double strokeWidth;

  LaurelBranchPainter({
    required this.isLeft,
    required this.isDark,
    this.strokeWidth = 1.6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    if (isLeft) {
      // Curve bending outward to the left
      path.moveTo(w, h);
      path.quadraticBezierTo(0, h * 0.5, w * 0.8, 0);
      canvas.drawPath(path, paint);

      // Draw leaves along the curve
      _drawLeaf(canvas, fillPaint, Offset(w * 0.7, h * 0.15), -0.8, size);
      _drawLeaf(canvas, fillPaint, Offset(w * 0.3, h * 0.38), -1.2, size);
      _drawLeaf(canvas, fillPaint, Offset(w * 0.3, h * 0.62), -1.6, size);
      _drawLeaf(canvas, fillPaint, Offset(w * 0.6, h * 0.85), -2.0, size);
    } else {
      // Curve bending outward to the right
      path.moveTo(0, h);
      path.quadraticBezierTo(w, h * 0.5, w * 0.2, 0);
      canvas.drawPath(path, paint);

      // Draw leaves along the curve
      _drawLeaf(canvas, fillPaint, Offset(w * 0.3, h * 0.15), 0.8, size);
      _drawLeaf(canvas, fillPaint, Offset(w * 0.7, h * 0.38), 1.2, size);
      _drawLeaf(canvas, fillPaint, Offset(w * 0.7, h * 0.62), 1.6, size);
      _drawLeaf(canvas, fillPaint, Offset(w * 0.4, h * 0.85), 2.0, size);
    }
  }

  void _drawLeaf(
    Canvas canvas,
    Paint fillPaint,
    Offset center,
    double angle,
    Size size,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final leafPath = Path();
    final leafLength = size.height * 0.18;
    final leafWidth = size.width * 0.35;
    leafPath.moveTo(0, -leafLength / 2);
    leafPath.quadraticBezierTo(leafWidth, 0, 0, leafLength / 2);
    leafPath.quadraticBezierTo(-leafWidth, 0, 0, -leafLength / 2);
    canvas.drawPath(leafPath, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LaurelBranchPainter oldDelegate) =>
      oldDelegate.isLeft != isLeft ||
      oldDelegate.isDark != isDark ||
      oldDelegate.strokeWidth != strokeWidth;
}
