import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1976D2), // Blue app bar
        foregroundColor: Colors.white, // White text
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF0D47A1), // Dark Blue button
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1), // Dark Blue button
          foregroundColor: Colors.white, // White text color
          minimumSize: const Size(200, 50), // Uniform button size
        ),
      ),
    );
  }
}
