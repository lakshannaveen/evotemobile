import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF0D47A1),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D3258),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }

  // Admin Theme
  static ThemeData get adminTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.red,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  // Admin Dark Theme
  static ThemeData get adminDarkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.red,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
        ),
      ),
    );
  }
}