import 'package:evoteapp/pages/Guidlines.dart';
import 'package:evoteapp/pages/cast_page.dart';
import 'package:evoteapp/pages/contact_us.dart';
import 'package:evoteapp/pages/election_not_active_page.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:evoteapp/pages/admin_login_page.dart';
import 'package:flutter/material.dart';
import 'package:evoteapp/services/admin_dashboard_service.dart';
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
      home: const ElectionStatusCheck(),
      routes: {
        '/home': (context) => const HomePage(),
        '/votelogin': (context) => const VoteLoginPage(),
        '/results': (context) => const ResultPage(),
        '/admin': (context) => const AdminLoginPage(),
        '/contactus': (context) => const ContactUsPage(),
        '/guidlines': (context) => const GuidelinePage(),
        '/verify': (context) => VerifyPage(),
        '/cast': (context) => CastPage(),
      },
    );
  }
}

// Widget to check election status before showing content
class ElectionStatusCheck extends StatelessWidget {
  const ElectionStatusCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminDashboardService dashboardService = AdminDashboardService();
    
    // Stream builder to listen to election status
    return StreamBuilder<Map<String, dynamic>>(
      stream: dashboardService.getElectionStatus(),
      builder: (context, snapshot) {
        // Show loading indicator while getting status
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final electionData = snapshot.data!;
        final isActive = electionData['isActive'] as bool;
        final status = electionData['status'] as String;
        
        // If election is active, show normal home page
        if (isActive) {
          return const HomePage();
        }
        
        // If not active, show the election not active page
        return ElectionNotActivePage(status: status);
      },
    );
  }
}
