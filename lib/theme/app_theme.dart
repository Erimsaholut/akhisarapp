import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData getAppTheme() {
  return ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: kOliveGreenPrimary,
      onPrimary: Colors.white,
      secondary: kSageGreenSecondary,
      onSecondary: kDarkText,
      background: kBeigeBackground,
      onBackground: kDarkText,
      surface: kCardSurface,
      onSurface: kDarkText,
      error: kTerracottaAccent,
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: kBeigeBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: kOliveGreenPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: kDarkText, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: kDarkText, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: kDarkText, fontSize: 16, height: 1.4),
      labelMedium: TextStyle(color: kSageGreenSecondary, fontSize: 12),
    ),

    cardTheme: CardTheme(
      color: kCardSurface,
      elevation: 1,
      shadowColor: kSageGreenSecondary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kCardSurface,
      hintStyle: const TextStyle(color: kSageGreenSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        borderSide: BorderSide(color: kOliveGreenPrimary, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kOliveGreenPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24,
        ), // Butonun dikey ve yatay boyutu
        textStyle: const TextStyle(
          fontSize: 18, // Yazı büyüklüğü
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}