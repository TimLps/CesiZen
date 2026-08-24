import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/theme/admin_theme.dart';

/// Expressions disponibles pour le widget [CesiEmoji].
enum CesiEmotion {
  empty, plus, neutral, joy, anger, fear, sadness, surprise, disgust,
}

CesiEmotion cesiEmotionFromCategoryName(String? name) {
  switch (name?.toLowerCase().trim()) {
    case 'joie':              return CesiEmotion.joy;
    case 'colère':
    case 'colere':            return CesiEmotion.anger;
    case 'peur':              return CesiEmotion.fear;
    case 'tristesse':         return CesiEmotion.sadness;
    case 'surprise':          return CesiEmotion.surprise;
    case 'dégoût':
    case 'degout':            return CesiEmotion.disgust;
    default:                  return CesiEmotion.neutral;
  }
}

/// Émoji circulaire CESI Zen (3 anneaux + expression sans bouche).
class CesiEmoji extends StatelessWidget {
  const CesiEmoji({
    super.key,
    required this.emotion,
    this.size = 80,
    this.tintColor,
  });

  final CesiEmotion emotion;
  final double size;
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CesiEmojiPainter(
          emotion: emotion,
          outerColor: tintColor ?? AdminColors.azurPastel,
        ),
      ),
    );
  }
}

class _CesiEmojiPainter extends CustomPainter {
  _CesiEmojiPainter({required this.emotion, required this.outerColor});

  final CesiEmotion emotion;
  final Color outerColor;

  static const double _eyeOffsetX = 0.22;
  static const double _eyeOffsetY = 0.05;
  static const double _eyeRadius  = 0.10;
  static const double _browOffsetY = -0.20;
  static const double _browSpread = 0.14;
  static const double _strokeWidth = 0.085;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final r = math.min(w, h) / 2;

    canvas.drawCircle(center, r, Paint()..color = outerColor);
    canvas.drawCircle(center, r * 0.82, Paint()..color = AdminColors.lavande);
    canvas.drawCircle(center, r * 0.66, Paint()..color = AdminColors.azurClair);

    Paint stroke() => Paint()
      ..color = AdminColors.ardoiseClair
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(2.2, r * _strokeWidth);

    Paint fill() => Paint()..color = AdminColors.ardoiseClair;

    switch (emotion) {
      case CesiEmotion.empty:
        _drawText(canvas, center, '?', r);
        break;
      case CesiEmotion.plus:
        _drawText(canvas, center, '+', r * 1.1);
        break;
      case CesiEmotion.neutral:
        _drawDotEyes(canvas, center, r, fill());
        break;
      case CesiEmotion.joy:
        _drawCurvedEyesUp(canvas, center, r, stroke());
        break;
      case CesiEmotion.anger:
        _drawDotEyes(canvas, center, r, fill());
        _drawAngerBrows(canvas, center, r, stroke());
        break;
      case CesiEmotion.fear:
        _drawDotEyes(canvas, center, r, fill());
        _drawFearBrows(canvas, center, r, stroke());
        break;
      case CesiEmotion.sadness:
        _drawDotEyes(canvas, center, r, fill());
        _drawSadBrows(canvas, center, r, stroke());
        _drawTear(canvas, center, r);
        break;
      case CesiEmotion.surprise:
        _drawSurprisedEyes(canvas, center, r, stroke());
        break;
      case CesiEmotion.disgust:
        _drawDotEyes(canvas, center, r, fill());
        _drawDisgustBrows(canvas, center, r, stroke());
        break;
    }
  }

  void _drawDotEyes(Canvas c, Offset center, double r, Paint p) {
    final eyeR = r * _eyeRadius;
    c.drawCircle(center.translate(-r * _eyeOffsetX, r * _eyeOffsetY), eyeR, p);
    c.drawCircle(center.translate(r * _eyeOffsetX, r * _eyeOffsetY), eyeR, p);
  }

  void _drawCurvedEyesUp(Canvas c, Offset center, double r, Paint p) {
    void arc(Offset eye) {
      final rect = Rect.fromCenter(center: eye, width: r * 0.30, height: r * 0.24);
      c.drawArc(rect, math.pi, math.pi, false, p);
    }
    arc(center.translate(-r * _eyeOffsetX, r * (_eyeOffsetY + 0.02)));
    arc(center.translate(r * _eyeOffsetX, r * (_eyeOffsetY + 0.02)));
  }

  void _drawSurprisedEyes(Canvas c, Offset center, double r, Paint p) {
    final eyeR = r * 0.13;
    c.drawCircle(center.translate(-r * _eyeOffsetX, r * _eyeOffsetY), eyeR, p);
    c.drawCircle(center.translate(r * _eyeOffsetX, r * _eyeOffsetY), eyeR, p);
  }

  void _drawAngerBrows(Canvas c, Offset center, double r, Paint p) {
    final yTop = r * (_browOffsetY - 0.02);
    final yBottom = r * (_browOffsetY + 0.10);
    final xOuter = r * (_eyeOffsetX + _browSpread);
    final xInner = r * (_eyeOffsetX - _browSpread);
    c.drawPath(Path()
      ..moveTo(center.dx - xOuter, center.dy + yTop)
      ..lineTo(center.dx - xInner, center.dy + yBottom), p);
    c.drawPath(Path()
      ..moveTo(center.dx + xInner, center.dy + yBottom)
      ..lineTo(center.dx + xOuter, center.dy + yTop), p);
  }

  void _drawFearBrows(Canvas c, Offset center, double r, Paint p) {
    void arc(Offset eye) {
      final rect = Rect.fromCenter(center: eye, width: r * 0.32, height: r * 0.18);
      c.drawArc(rect, math.pi, math.pi, false, p);
    }
    arc(center.translate(-r * _eyeOffsetX, r * _browOffsetY));
    arc(center.translate(r * _eyeOffsetX, r * _browOffsetY));
  }

  void _drawSadBrows(Canvas c, Offset center, double r, Paint p) {
    final yInner = r * (_browOffsetY - 0.02);
    final yOuter = r * (_browOffsetY + 0.08);
    final xOuter = r * (_eyeOffsetX + _browSpread);
    final xInner = r * (_eyeOffsetX - _browSpread + 0.04);
    c.drawPath(Path()
      ..moveTo(center.dx - xOuter, center.dy + yOuter)
      ..lineTo(center.dx - xInner, center.dy + yInner), p);
    c.drawPath(Path()
      ..moveTo(center.dx + xInner, center.dy + yInner)
      ..lineTo(center.dx + xOuter, center.dy + yOuter), p);
  }

  void _drawDisgustEyes(Canvas c, Offset center, double r, Paint stroke, Paint fill) {
    // Œil gauche : point plein (normal)
    c.drawCircle(
      center.translate(-r * _eyeOffsetX, r * _eyeOffsetY),
      r * _eyeRadius,
      fill,
    );
    // Œil droit : plissé (arc concave vers le haut)
    final eyeRect = Rect.fromCenter(
      center: center.translate(r * _eyeOffsetX, r * (_eyeOffsetY + 0.04)),
      width: r * 0.28,
      height: r * 0.18,
    );
    c.drawArc(eyeRect, 0, math.pi, false, stroke);
  }

  void _drawDisgustBrows(Canvas c, Offset center, double r, Paint p) {
    // Sourcil gauche haussé en arc
    final leftRect = Rect.fromCenter(
      center: center.translate(-r * _eyeOffsetX, r * (_browOffsetY - 0.02)),
      width: r * 0.34,
      height: r * 0.20,
    );
    c.drawArc(leftRect, math.pi, math.pi, false, p);

    // Sourcil droit baissé/froncé
    final yOuter = r * (_browOffsetY + 0.04);
    final yInner = r * (_browOffsetY + 0.10);
    final xOuter = r * (_eyeOffsetX + _browSpread);
    final xInner = r * (_eyeOffsetX - _browSpread + 0.02);
    c.drawPath(Path()
      ..moveTo(center.dx + xInner, center.dy + yInner)
      ..lineTo(center.dx + xOuter, center.dy + yOuter), p);
  }

  void _drawNoseWrinkle(Canvas c, Offset center, double r) {
    final wrinkle = Paint()
      ..color = AdminColors.ardoiseClair
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.6, r * 0.05);
    for (int i = 0; i < 3; i++) {
      final dx = (i - 1) * r * 0.045;
      final y = center.dy + r * 0.22;
      c.drawLine(
        Offset(center.dx + dx - r * 0.04, y),
        Offset(center.dx + dx + r * 0.04, y - r * 0.05),
        wrinkle,
      );
    }
  }

  void _drawTear(Canvas c, Offset center, double r) {
    final tipX = center.dx - r * 0.30;
    final topY = center.dy + r * 0.16;
    final bottomY = center.dy + r * 0.42;
    final width = r * 0.10;
    final tear = Path()
      ..moveTo(tipX, topY)
      ..quadraticBezierTo(tipX - width, (topY + bottomY) / 2, tipX, bottomY)
      ..quadraticBezierTo(tipX + width, (topY + bottomY) / 2, tipX, topY)
      ..close();
    c.drawPath(tear, Paint()..color = AdminColors.azurPastel);
    c.drawPath(tear,
        Paint()
          ..color = AdminColors.ardoiseClair
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, r * 0.025)
          ..strokeJoin = StrokeJoin.round);
  }

  void _drawText(Canvas c, Offset center, String text, double r) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: AdminColors.ardoiseClair,
          fontSize: r * 0.9,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center.translate(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CesiEmojiPainter oldDelegate) {
    return oldDelegate.emotion != emotion || oldDelegate.outerColor != outerColor;
  }
}
