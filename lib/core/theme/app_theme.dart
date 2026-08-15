import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_spacing.dart';

// Minimal, premium theme built around a single vivid accent, borders instead
// of heavy shadows, and an explicit type scale so every screen reuses the
// same hierarchy instead of ad-hoc TextStyles. Shares its structure with the
// sibling GymApp theme for cross-app consistency, but swaps the accent
// (coral vs. GymApp's teal) and adds macro-specific tints so MacrosApp reads
// as its own product rather than a reskin. Both `dark` and `light` are built
// from the same `_build()` so every ThemeData property stays in sync between
// the two — declared once here rather than duplicated per brightness.
class AppTheme {
  AppTheme._();

  static const accent = Color(0xFFFF7A59);

  // Dark palette — near-black with a warm-neutral tint (not pure grey).
  static const background = Color(0xFF0A0C0E);
  static const surface = Color(0xFF15181B);
  static const surfaceRaised = Color(0xFF1C2024);
  static const border = Color(0xFF262B30);

  // Light palette — warm off-white, mirrors the dark scale's roles 1:1.
  static const backgroundLight = Color(0xFFFAFAF9);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceRaisedLight = Color(0xFFF1F0EE);
  static const borderLight = Color(0xFFE5E3E0);

  // Pastel palette — cotton-candy pink on white, its own accent instead of
  // the coral used by dark/light so it reads as a distinct "skin" rather
  // than a tinted light mode.
  static const pastelAccent = Color(0xFFFF6FA5);
  static const pastelOnAccent = Color(0xFF3D1330);
  static const backgroundPastel = Color(0xFFFFF6FB);
  static const surfacePastel = Color(0xFFFFFFFF);
  static const surfaceRaisedPastel = Color(0xFFFCE4F0);
  static const borderPastel = Color(0xFFF6D3E6);

  // Macro-specific tints — used consistently by progress bars, chips and
  // legends so a macro is identifiable by color alone across every screen.
  // Same in both themes: these are identity colors, not surface colors.
  static const carbsColor = Color(0xFFFBBF24);
  static const proteinColor = Color(0xFFC084FC);
  static const fatColor = Color(0xFF60A5FA);

  // Status colors shared by the calorie ring, weight trend and validation
  // states — named statics so every screen references the same palette.
  static const statusOverTarget = Color(0xFFF87171);
  static const statusOnTrack = Color(0xFF34D399);
  static const statusEmpty = Color(0xFF3A3F45);

  // Soft directional shadow shared by every raised surface (cards, the date
  // capsule) — negative spread keeps it tight to the shape instead of a
  // generic blur, which is what makes it read as a subtle lift rather than a
  // Material drop shadow. Tuned per-brightness since a dark-mode shadow
  // needs far more opacity to register against a near-black background.
  static List<BoxShadow> softShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 10),
        spreadRadius: -14,
      ),
    ];
  }

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        background: background,
        surface: surface,
        surfaceRaised: surfaceRaised,
        border: border,
        textColor: const Color(0xFFF4F5F6),
        mutedTextColor: const Color(0xFF9CA3AB),
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        background: backgroundLight,
        surface: surfaceLight,
        surfaceRaised: surfaceRaisedLight,
        border: borderLight,
        textColor: const Color(0xFF1A1C1E),
        mutedTextColor: const Color(0xFF6B7076),
      );

  static ThemeData get pastel => _build(
        brightness: Brightness.light,
        background: backgroundPastel,
        surface: surfacePastel,
        surfaceRaised: surfaceRaisedPastel,
        border: borderPastel,
        textColor: const Color(0xFF4A2942),
        mutedTextColor: const Color(0xFF9B7C93),
        accentColor: pastelAccent,
        onAccentColor: pastelOnAccent,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceRaised,
    required Color border,
    required Color textColor,
    required Color mutedTextColor,
    Color accentColor = accent,
    Color onAccentColor = const Color(0xFF2A0E06),
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: brightness,
      surface: surface,
    );

    // Display face: Outfit — a geometric sans with a confident, sporty
    // character for numbers and headings. Body face: Plus Jakarta Sans —
    // warm and highly legible at small sizes for stat-dense screens. Same
    // pairing as GymApp so the two apps share a typographic identity.
    TextStyle display(TextStyle style) => GoogleFonts.outfit(textStyle: style);
    TextStyle body(TextStyle style) => GoogleFonts.plusJakartaSans(textStyle: style);

    final textTheme = TextTheme(
      // Hero numbers / big CTAs.
      displaySmall: display(TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textColor,
        height: 1.1,
      )),
      headlineMedium: display(TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: textColor,
      )),
      titleLarge: display(TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: textColor,
      )),
      titleMedium: display(TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      )),
      bodyLarge: body(TextStyle(fontSize: 16, color: textColor, height: 1.35)),
      bodyMedium: body(TextStyle(fontSize: 14, color: textColor, height: 1.35)),
      bodySmall: body(TextStyle(fontSize: 13, color: mutedTextColor, height: 1.3)),
      labelLarge: body(TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
      labelMedium: body(TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mutedTextColor)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme.copyWith(
        surface: surface,
        surfaceContainerHighest: surfaceRaised,
        onSurface: textColor,
        outline: border,
      ),
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: display(TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textColor,
        )),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: border),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: mutedTextColor,
        textColor: textColor,
      ),
      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceRaised,
        selectedColor: accentColor.withValues(alpha: 0.22),
        labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: onAccentColor,
          disabledBackgroundColor: surfaceRaised,
          textStyle: display(const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: accentColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accentColor.withValues(alpha: 0.18),
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? textColor : mutedTextColor,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        showDragHandle: true,
        dragHandleColor: border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceRaised,
        contentTextStyle: TextStyle(color: textColor),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accentColor),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: surfaceRaised,
          selectedBackgroundColor: accentColor.withValues(alpha: 0.22),
          side: BorderSide(color: border),
        ),
      ),
    );
  }
}
