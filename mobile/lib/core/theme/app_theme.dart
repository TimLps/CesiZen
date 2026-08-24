import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette CESI Zen — fixée par la charte graphique du dossier de conception.
///
/// Conformité RGAA / WCAG AA :
///   - `ardoiseClair` (#778899) reste utilisée pour tous les éléments graphiques
///     (icônes, illustrations, logos, traits des emojis, titres ≥18 pt bold).
///   - Pour le texte courant (body), on utilise `textPrimary` (#566069) qui
///     atteint un ratio de contraste ≥ 5.4 sur fond clair (AA conforme).
///   - `textSecondary` et `textMuted` sont également renforcés.
class CesiColors {
  // ── Charte officielle (graphique) ────────────────────────────────────────
  static const Color lavande      = Color(0xFFE6E6FA); // Rose Pâle / lavande
  static const Color azurPastel   = Color(0xFFB0E0E6); // Azur Pastel
  static const Color ardoiseClair = Color(0xFF778899); // Gris Ardoise Clair
  static const Color azurClair    = Color(0xFFF0F8FF); // Azur Clair (background)

  // ── Dérivées d'usage ─────────────────────────────────────────────────────
  static const Color primary      = azurPastel;
  static const Color primaryDark  = ardoiseClair;
  static const Color secondary    = lavande;
  static const Color background   = azurClair;
  static const Color cardBg       = Colors.white;
  static const Color cardBgSoft   = Color(0xFFF3F1FA);

  // Texte courant : version foncée d'ardoiseClair pour respecter AA.
  static const Color textPrimary   = Color(0xFF566069);
  static const Color textSecondary = Color(0xFF6B7680);
  static const Color textMuted     = Color(0xFF7A8590);

  static const Color border       = Color(0xFFE2E6EC);
  static const Color borderSoft   = Color(0xFFEEF1F5);

  // ── Statut ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF7ED9B5);
  static const Color warning = Color(0xFFFFD580);
  static const Color error   = Color(0xFFE88B8B);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    final textTheme = GoogleFonts.montserratTextTheme(base.textTheme).apply(
      bodyColor: CesiColors.textPrimary,
      displayColor: CesiColors.textPrimary,
    );

    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: CesiColors.background,
      colorScheme: const ColorScheme.light(
        primary: CesiColors.primary,
        onPrimary: CesiColors.textPrimary,
        secondary: CesiColors.secondary,
        onSecondary: CesiColors.textPrimary,
        surface: Colors.white,
        onSurface: CesiColors.textPrimary,
        error: CesiColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        headlineMedium: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CesiColors.background,
        foregroundColor: CesiColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: CesiColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: CesiColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: CesiColors.cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CesiColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CesiColors.primary,
          foregroundColor: CesiColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CesiColors.primaryDark,
          side: const BorderSide(color: CesiColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CesiColors.primaryDark,
          textStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.montserrat(color: CesiColors.textMuted),
        labelStyle: GoogleFonts.montserrat(color: CesiColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CesiColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CesiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CesiColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CesiColors.error),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: CesiColors.primaryDark,
        unselectedItemColor: CesiColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      dividerTheme: const DividerThemeData(color: CesiColors.borderSoft, thickness: 1, space: 1),
    );
  }
}
