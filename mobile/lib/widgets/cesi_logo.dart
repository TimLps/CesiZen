import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Logo officiel CESI Zen — visage avec un clin d'œil, dans le style sans bouche
/// du dossier de conception (cf. assets/maquettes/1.png).
class CesiLogo extends StatelessWidget {
  final double size;
  final bool withText;
  final bool dark;

  const CesiLogo({
    super.key,
    this.size = 100,
    this.withText = false,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CesiLogoPainter()),
        ),
        if (withText) ...[
          SizedBox(height: size * 0.18),
          Text(
            'CESI ZEN',
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: dark ? Colors.white : CesiColors.textPrimary,
            ),
          ),
          SizedBox(height: size * 0.04),
          Text(
            'Bien pour demain',
            style: TextStyle(
              fontSize: size * 0.11,
              color: dark ? Colors.white70 : CesiColors.textMuted,
              letterSpacing: 0.5,
            ),
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

    // 3 anneaux concentriques
    canvas.drawCircle(center, r, Paint()..color = CesiColors.azurPastel);
    canvas.drawCircle(center, r * 0.82, Paint()..color = CesiColors.lavande);
    canvas.drawCircle(center, r * 0.66, Paint()..color = CesiColors.azurClair);

    final ink = Paint()
      ..color = CesiColors.ardoiseClair
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2, r * 0.08);

    // Clin d'œil gauche : arc semi-circulaire ︶
    final wink = Rect.fromCenter(
      center: center.translate(-r * 0.2, r * 0.04),
      width: r * 0.22,
      height: r * 0.16,
    );
    canvas.drawArc(wink, math.pi, math.pi, false, ink);

    // Œil droit : point plein
    canvas.drawCircle(
      center.translate(r * 0.2, r * 0.04),
      r * 0.07,
      Paint()..color = CesiColors.ardoiseClair,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
