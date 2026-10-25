import 'package:flutter/material.dart';

/// App colors. Warm white and orange, with a dark version.
/// Change the colors here and the whole app will follow.
class AppColors {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.border,
    required this.text,
    required this.muted,
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.green,
    required this.greenDark,
    required this.greenSoft,
    required this.blue,
    required this.purple,
    required this.pink,
  });

  final Color bg;
  final Color surface;
  final Color border;
  final Color text;
  final Color muted;
  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color green;
  final Color greenDark;
  final Color greenSoft;
  final Color blue;
  final Color purple;
  final Color pink;

  static const light = AppColors(
    bg: Color(0xFFFFF8F1),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFF1E3D6),
    text: Color(0xFF3B2A20),
    muted: Color(0xFF8C7B70),
    primary: Color(0xFFFF8A3D),
    primaryDark: Color(0xFFE0681C),
    primarySoft: Color(0xFFFFE6D3),
    green: Color(0xFF6CBF4B),
    greenDark: Color(0xFF4F9A33),
    greenSoft: Color(0xFFE3F4DA),
    blue: Color(0xFF5AA9E6),
    purple: Color(0xFF9B7FE0),
    pink: Color(0xFFF28DA8),
  );

  static const dark = AppColors(
    bg: Color(0xFF1C1714),
    surface: Color(0xFF28211C),
    border: Color(0xFF3A3029),
    text: Color(0xFFF6EDE6),
    muted: Color(0xFFB3A398),
    primary: Color(0xFFFF9A52),
    primaryDark: Color(0xFFC96A27),
    primarySoft: Color(0xFF4A3021),
    green: Color(0xFF7ACB59),
    greenDark: Color(0xFF4E8A36),
    greenSoft: Color(0xFF2C3B24),
    blue: Color(0xFF6DB4EA),
    purple: Color(0xFFAA92E8),
    pink: Color(0xFFF29AB2),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme.fromSeed(seedColor: c.primary, brightness: brightness).copyWith(
    primary: c.primary,
    onPrimary: Colors.white,
    surface: c.surface,
    onSurface: c.text,
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: c.border, width: 2),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: c.text, fontSize: 20, fontWeight: FontWeight.w800),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.primarySoft,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.text),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      hintStyle: TextStyle(color: c.muted),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(borderSide: BorderSide(color: c.primary, width: 2)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.text,
      contentTextStyle: TextStyle(color: c.bg, fontWeight: FontWeight.w700),
    ),
  );
}
