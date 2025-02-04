import 'package:flutter/material.dart';
import 'config/theme.dart'; // Import theme file
import 'pages/home_page.dart';
import 'pages/vote_login_page.dart';
import 'pages/result_page.dart';

void main() {
  runApp(const MyApp()); // Runs the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes debug banner
      title: 'E-Vote App',
      theme: AppTheme.lightTheme, // Applying theme from theme.dart
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/votelogin': (context) => const VoteLoginPage(),
        '/results': (context) => const ResultPage(),
      },
    );
  }
}
