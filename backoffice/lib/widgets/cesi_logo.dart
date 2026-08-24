import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/theme/admin_theme.dart';

/// Logo officiel CESI Zen — visage avec un clin d'œil, dans le style sans bouche
/// du dossier de conception. Version Web/desktop pour le back-office.
class CesiLogo extends StatelessWidget {
  final double size;
  final bool withText;

  const CesiLogo({super.key, this.size = 100, this.withText = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CesiLogoPainter()),
        ),
        if (withText) ...[
          SizedBox(width: size * 0.18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CESI ZEN',
                style: TextStyle(
                  fontSize: size * 0.40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AdminColors.textPrimary,
                ),
              ),
              Text(
                'Administration',
                style: TextStyle(
                  fontSize: size * 0.20,
                  color: AdminColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CesiLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final r = math.min(w, h) / 2;

    canvas.drawCircle(center, r, Paint()..color = AdminColors.azurPastel);
    canvas.drawCircle(center, r * 0.82, Paint()..color = AdminColors.lavande);
    canvas.drawCircle(center, r * 0.66, Paint()..color = AdminColors.azurClair);

    final ink = Paint()
      ..color = AdminColors.ardoiseClair
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2, r * 0.08);

    final wink = Rect.fromCenter(
      center: center.translate(-r * 0.2, r * 0.04),
      width: r * 0.22,
      height: r * 0.16,
    );
    canvas.drawArc(wink, math.pi, math.pi, false, ink);

    canvas.drawCircle(
      center.translate(r * 0.2, r * 0.04),
      r * 0.07,
      Paint()..color = AdminColors.ardoiseClair,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
