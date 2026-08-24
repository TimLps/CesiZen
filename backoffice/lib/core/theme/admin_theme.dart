import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminColors {
  // Charte CESI Zen
  static const Color lavande      = Color(0xFFE6E6FA);
  static const Color azurPastel   = Color(0xFFB0E0E6);
  static const Color ardoiseClair = Color(0xFF778899);
  static const Color azurClair    = Color(0xFFF0F8FF);

  static const Color primary       = azurPastel;
  static const Color primaryDark   = ardoiseClair;
  static const Color sidebar       = Colors.white;
  static const Color sidebarActive = lavande;

  static const Color background    = azurClair;
  static const Color cardBg        = Colors.white;
  static const Color border        = Color(0xFFE2E6EC);

  // Texte courant foncé pour respecter le ratio de contraste WCAG AA (4.5:1).
  // ardoiseClair (#778899) reste utilisée pour les éléments graphiques.
  static const Color textPrimary   = Color(0xFF566069);
  static const Color textSecondary = Color(0xFF6B7680);
  static const Color textMuted     = Color(0xFF7A8590);

  // Statuts
  static const Color success = Color(0xFF7ED9B5);
  static const Color warning = Color(0xFFFFD580);
  static const Color error   = Color(0xFFE88B8B);

  // KPI cards
  static const Color kpiBlue    = azurPastel;
  static const Color kpiGreen   = Color(0xFFB6E5C5);
  static const Color kpiYellow  = Color(0xFFFFF2CC);
  static const Color kpiPurple  = lavande;
  static const Color kpiPink    = Color(0xFFF8C8D8);
}

class AdminTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    final textTheme = GoogleFonts.montserratTextTheme(base.textTheme).apply(
      bodyColor: AdminColors.textPrimary,
      displayColor: AdminColors.textPrimary,
    );

    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AdminColors.background,
      colorScheme: const ColorScheme.light(
        primary: AdminColors.primaryDark,
        onPrimary: Colors.white,
        secondary: AdminColors.primary,
        onSecondary: AdminColors.textPrimary,
        surface: Colors.white,
        onSurface: AdminColors.textPrimary,
        error: AdminColors.error,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AdminColors.textPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AdminColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AdminColors.textPrimary),
        shape: const Border(
          bottom: BorderSide(color: AdminColors.border, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: AdminColors.cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AdminColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primary,        // azur pastel (charte mobile)
          foregroundColor: AdminColors.textPrimary,    // texte ardoise foncée
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.montserrat(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.primaryDark,
          side: const BorderSide(color: AdminColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.montserrat(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AdminColors.primary, width: 2),
        ),
      ),
      dividerColor: AdminColors.border,
      dataTableTheme: DataTableThemeData(
        headingRowColor:
            WidgetStatePropertyAll(AdminColors.background.withOpacity(0.5)),
        headingTextStyle: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AdminColors.textSecondary,
        ),
        dataTextStyle: GoogleFonts.montserrat(
          fontSize: 13,
          color: AdminColors.textPrimary,
        ),
      ),
    );
  }
}
