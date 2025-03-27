import 'package:evoteapp/pages/Guidelines.dart';
import 'package:evoteapp/pages/cast_page.dart';
import 'package:evoteapp/pages/contact_us.dart';
import 'package:evoteapp/pages/election_not_active_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:evoteapp/pages/admin_login_page.dart';
import 'package:flutter/material.dart';
import 'package:evoteapp/services/admin_dashboard_service.dart';
import 'package:evoteapp/services/theme_provider.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'pages/home_page.dart';
import 'pages/vote_login_page.dart';
import 'pages/result_page.dart';
import 'pages/verify_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Vote App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/votelogin': (context) => const VoteLoginPage(),
        '/results': (context) => const ResultPage(),
        '/admin': (context) => const AdminLoginPage(),
        '/contactus': (context) => const ContactUsPage(),
        '/guidelines': (context) => const GuidelinePage(), // Fixed this line
        '/verify': (context) => VerifyPage(),
        '/cast': (context) => CastPage(),
      },
    );
  }
}