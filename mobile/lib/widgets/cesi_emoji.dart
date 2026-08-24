import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Expressions disponibles pour le widget [CesiEmoji].
///
/// Inspirées de la maquette officielle CESI Zen (cf. dossier de conception) :
/// - aucune émotion n'a de bouche : c'est l'identité graphique du projet
/// - chaque expression se distingue uniquement par les yeux et sourcils.
enum CesiEmotion {
  empty,    // "?" pour fallback
  plus,     // "+" pour inciter à la saisie
  neutral,  // deux yeux ronds, rien d'autre
  joy,      // yeux courbés vers le haut ︶ ︶
  anger,    // sourcils en V froncé
  fear,     // sourcils en arc descendant ︵ ︵
  sadness,  // sourcils tombants + larme
  surprise, // yeux très ronds et grands, écarquillés
  disgust,  // sourcil gauche haussé, droit froncé
}

/// Convertit un nom de catégorie d'émotion (depuis l'API) en expression visuelle.
CesiEmotion cesiEmotionFromCategoryName(String? name) {
  switch (name?.toLowerCase().trim()) {
    case 'joie':
      return CesiEmotion.joy;
    case 'colère':
    case 'colere':
      return CesiEmotion.anger;
    case 'peur':
      return CesiEmotion.fear;
    case 'tristesse':
      return CesiEmotion.sadness;
    case 'surprise':
      return CesiEmotion.surprise;
    case 'dégoût':
    case 'degout':
      return CesiEmotion.disgust;
    default:
      return CesiEmotion.neutral;
  }
}

/// Émoji circulaire à trois anneaux (azur extérieur, lavande, blanc intérieur)
/// avec une expression au centre dessinée dans le style CESI Zen.
class CesiEmoji extends StatelessWidget {
  const CesiEmoji({
    super.key,
    required this.emotion,
    this.size = 120,
    this.tintColor,
  });

  final CesiEmotion emotion;
  final double size;

  /// Couleur de teinte de l'anneau extérieur (par défaut : azur pastel).
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CesiEmojiPainter(
          emotion: emotion,
          outerColor: tintColor ?? CesiColors.azurPastel,
        ),
      ),
    );
  }
}

class _CesiEmojiPainter extends CustomPainter {
  _CesiEmojiPainter({required this.emotion, required this.outerColor});

  final CesiEmotion emotion;
  final Color outerColor;

  // ── Constantes géométriques (proportion / r) ─────────────────────────────
  // r = rayon du cercle extérieur
  static const double _eyeOffsetX = 0.22;  // distance horizontale au centre
  static const double _eyeOffsetY = 0.05;  // un poil sous le milieu
  static const double _eyeRadius  = 0.10;  // bonne visibilité même à 60px
  static const double _browOffsetY = -0.20;
  static const double _browSpread = 0.14;
  static const double _strokeWidth = 0.085;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final r = math.min(w, h) / 2;

    // Anneau 1 : extérieur azur pastel
    canvas.drawCircle(center, r, Paint()..color = outerColor);
    // Anneau 2 : lavande
    canvas.drawCircle(center, r * 0.82, Paint()..color = CesiColors.lavande);
    // Disque 3 : blanc cassé azur très clair
    canvas.drawCircle(center, r * 0.66, Paint()..color = CesiColors.azurClair);

    // Paint de référence (les méthodes de dessin construisent leurs propres
    // paints à partir de celui-ci pour rester indépendantes les unes des autres)
    Paint stroke() => Paint()
      ..color = CesiColors.ardoiseClair
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(2.2, r * _strokeWidth);

    Paint fill() => Paint()..color = CesiColors.ardoiseClair;

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

  // ── Yeux ──────────────────────────────────────────────────────────────────

  void _drawDotEyes(Canvas c, Offset center, double r, Paint p) {
    final eyeR = r * _eyeRadius;
    c.drawCircle(center.translate(-r * _eyeOffsetX, r * _eyeOffsetY), eyeR, p);
    c.drawCircle(center.translate(r * _eyeOffsetX, r * _eyeOffsetY), eyeR, p);
  }

  /// Joie : yeux courbés vers le haut "︶ ︶".
  void _drawCurvedEyesUp(Canvas c, Offset center, double r, Paint p) {
    void arc(Offset eye) {
      final rect = Rect.fromCenter(
        center: eye,
        width: r * 0.30,
        height: r * 0.24,
      );
      c.drawArc(rect, math.pi, math.pi, false, p);
    }
    arc(center.translate(-r * _eyeOffsetX, r * (_eyeOffsetY + 0.02)));
    arc(center.translate(r * _eyeOffsetX, r * (_eyeOffsetY + 0.02)));
  }

  /// Surprise : grands yeux écarquillés (cercles vides avec contour épais).
  void _drawSurprisedEyes(Canvas c, Offset center, double r, Paint p) {
    final eyeR = r * 0.13;
    c.drawCircle(center.translate(-r * _eyeOffsetX, r * _eyeOffsetY), eyeR, p);
    c.drawCircle(center.translate(r * _eyeOffsetX, r * _eyeOffsetY), eyeR, p);
  }

  // ── Sourcils ──────────────────────────────────────────────────────────────

  /// Colère : sourcils en V froncé (intérieurs vers le bas).
  /// Forme : `\\___/`  intérieurs vers le centre et le bas.
  void _drawAngerBrows(Canvas c, Offset center, double r, Paint p) {
    final yTop = r * (_browOffsetY - 0.02);     // côté extérieur, plus haut
    final yBottom = r * (_browOffsetY + 0.10);  // côté intérieur, plus bas
    final xOuter = r * (_eyeOffsetX + _browSpread);
    final xInner = r * (_eyeOffsetX - _browSpread);

    final left = Path()
      ..moveTo(center.dx - xOuter, center.dy + yTop)
      ..lineTo(center.dx - xInner, center.dy + yBottom);
    final right = Path()
      ..moveTo(center.dx + xInner, center.dy + yBottom)
      ..lineTo(center.dx + xOuter, center.dy + yTop);
    c.drawPath(left, p);
    c.drawPath(right, p);
  }

  /// Peur : sourcils relevés en arc, comme `︵ ︵`.
  /// Effet "inquiet" : extrémités plus basses, milieu remonte.
  void _drawFearBrows(Canvas c, Offset center, double r, Paint p) {
    void arc(Offset eye) {
      final rect = Rect.fromCenter(
        center: eye,
        width: r * 0.32,
        height: r * 0.18,
      );
      // Demi-arc supérieur (creux vers le bas)
      c.drawArc(rect, math.pi, math.pi, false, p);
    }
    arc(center.translate(-r * _eyeOffsetX, r * _browOffsetY));
    arc(center.translate(r * _eyeOffsetX, r * _browOffsetY));
  }

  /// Tristesse : sourcils tombants en V inversé (intérieurs hauts, extérieurs bas).
  /// Forme : `/-\` mais retournée → `\__/` symétriquement opposé à la colère.
  void _drawSadBrows(Canvas c, Offset center, double r, Paint p) {
    final yInner = r * (_browOffsetY - 0.02);   // côté intérieur, plus haut
    final yOuter = r * (_browOffsetY + 0.08);   // côté extérieur, plus bas
    final xOuter = r * (_eyeOffsetX + _browSpread);
    final xInner = r * (_eyeOffsetX - _browSpread + 0.04);

    final left = Path()
      ..moveTo(center.dx - xOuter, center.dy + yOuter)
      ..lineTo(center.dx - xInner, center.dy + yInner);
    final right = Path()
      ..moveTo(center.dx + xInner, center.dy + yInner)
      ..lineTo(center.dx + xOuter, center.dy + yOuter);
    c.drawPath(left, p);
    c.drawPath(right, p);
  }

  /// Dégoût : asymétrie marquée — un œil normal, un œil plissé.
  /// Sourcils très contrastés (un haut, un froncé), avec des ridules sur
  /// le nez pour suggérer le plissement (puisqu'on n'a pas de bouche).
  void _drawDisgustEyes(Canvas c, Offset center, double r, Paint stroke, Paint fill) {
    // Œil gauche : point plein (regard normal)
    c.drawCircle(
      center.translate(-r * _eyeOffsetX, r * _eyeOffsetY),
      r * _eyeRadius,
      fill,
    );
    // Œil droit : plissé — arc concave vers le haut (forme `︵` retournée),
    // comme si on louchait pour ne pas voir.
    final eyeRect = Rect.fromCenter(
      center: center.translate(r * _eyeOffsetX, r * (_eyeOffsetY + 0.04)),
      width: r * 0.28,
      height: r * 0.18,
    );
    c.drawArc(eyeRect, 0, math.pi, false, stroke);
  }

  /// Sourcils du dégoût : asymétrie forte — gauche haussé en arc (incrédule),
  /// droit baissé (froncé sur l'œil plissé).
  void _drawDisgustBrows(Canvas c, Offset center, double r, Paint p) {
    // Sourcil gauche : arc bombé (haussé)
    final leftRect = Rect.fromCenter(
      center: center.translate(-r * _eyeOffsetX, r * (_browOffsetY - 0.02)),
      width: r * 0.34,
      height: r * 0.20,
    );
    c.drawArc(leftRect, math.pi, math.pi, false, p);

    // Sourcil droit : trait quasi horizontal mais légèrement penché vers le bas,
    // très près de l'œil plissé (effet "froncé").
    final yOuter = r * (_browOffsetY + 0.04);
    final yInner = r * (_browOffsetY + 0.10);
    final xOuter = r * (_eyeOffsetX + _browSpread);
    final xInner = r * (_eyeOffsetX - _browSpread + 0.02);
    final right = Path()
      ..moveTo(center.dx + xInner, center.dy + yInner)
      ..lineTo(center.dx + xOuter, center.dy + yOuter);
    c.drawPath(right, p);
  }

  /// Ridules de nez : 3 petits traits diagonaux centrés au-dessus de la zone
  /// "nez", évoquent le plissement caractéristique du dégoût (style smiley 🤢).
  void _drawNoseWrinkle(Canvas c, Offset center, double r, Paint p) {
    final wrinkle = Paint()
      ..color = CesiColors.ardoiseClair
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

  // ── Accessoires ───────────────────────────────────────────────────────────

  /// Larme bleue claire qui coule depuis le coin extérieur de l'œil gauche.
  void _drawTear(Canvas c, Offset center, double r) {
    final tipX = center.dx - r * 0.30;
    final topY = center.dy + r * 0.16;
    final bottomY = center.dy + r * 0.42;
    final width = r * 0.10;

    // Forme de goutte : pointe en haut, base arrondie en bas
    final tear = Path()
      ..moveTo(tipX, topY)
      ..quadraticBezierTo(tipX - width, (topY + bottomY) / 2, tipX, bottomY)
      ..quadraticBezierTo(tipX + width, (topY + bottomY) / 2, tipX, topY)
      ..close();

    final fillPaint = Paint()..color = CesiColors.azurPastel;
    final strokePaint = Paint()
      ..color = CesiColors.ardoiseClair
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, r * 0.025)
      ..strokeJoin = StrokeJoin.round;

    c.drawPath(tear, fillPaint);
    c.drawPath(tear, strokePaint);
  }

  void _drawText(Canvas c, Offset center, String text, double r) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: CesiColors.ardoiseClair,
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
