import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  /// 🎨 Brand Colors
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color goldAccent = Color(0xFFF6DA00);
  static const Color textColor2 = Color(0xFF8e8e93);
  static const Color completedColor = Color(0xFF22C55E);
  static const Color inCompletedColor = Color(0xFFFFB300);
  static const Color buttonColor = Color(0xFF4838fc);
  static const Color backgroundColor = Color.fromARGB(255, 241, 241, 241);
  static const Color redColor = Color(0XFFFF383C);
  static const Color yellowColor = Color(0XFFFFCC00);
  static const Color greenColor = Color(0XFF34C759);
  static const Color purpleColor = Color(0XFF4a3aff);
  static const Color buttonColor2 = Color(0xFFe9e9ea);
  static const Color buttonColor3 = Color(0xFF007aff);

  /// 🌞 Light Theme
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: backgroundColor,
      primary: backgroundColor,
      secondary: goldAccent,
    ),
    scaffoldBackgroundColor: backgroundColor,

    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        headlineSmall: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Colors.black,
          fontSize: 38,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: Colors.black,
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Colors.black, fontSize: 18, height: 1.2),
        bodyMedium: TextStyle(color: Colors.black, fontSize: 16, height: 1.5),
        bodySmall: TextStyle(
          color: Colors.black,
          fontSize: 24, // now bodySmall is actually 24px
          height: 1.5,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  /// 🌙 Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      primary: primaryBlue,
      secondary: goldAccent,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(fontSize: 18, height: 1.2),
        bodyMedium: TextStyle(fontSize: 16, height: 1.5),
        bodySmall: TextStyle(fontSize: 13, height: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
