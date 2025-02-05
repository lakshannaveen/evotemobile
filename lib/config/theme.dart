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

  // Admin Theme
  static ThemeData get adminTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white, // White background for admin
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.red, // Red app bar
        foregroundColor: Colors.white,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.redAccent, // Red button
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent, // Red button
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red), // Red border on focus
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black), // Black border
        ),
        hintStyle: TextStyle(color: Colors.black), // Black placeholder text
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  }
}
