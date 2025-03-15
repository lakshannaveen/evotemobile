import 'package:evoteapp/pages/cast_page.dart';
import 'package:evoteapp/pages/contact_us.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:evoteapp/pages/admin_login_page.dart';
import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'pages/home_page.dart';
import 'pages/vote_login_page.dart';
import 'pages/result_page.dart';
import 'pages/verify_page.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure initialization before running app
  await Firebase.initializeApp(); // Initialize Firebase

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
        '/admin': (context) => const AdminLoginPage(),
        '/contactus': (context) => const ContactUsPage(),
        '/verify': (context) => VerifyPage(),
        '/cast': (context) => CastPage(),
      },
    );
  }
}
