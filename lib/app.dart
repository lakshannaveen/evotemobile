import 'package:flutter/material.dart';
import 'config/theme.dart'; // Import theme file
import 'pages/home_page.dart'; // Import home page

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes debug banner
      title: 'Voting App',
      theme: AppTheme.lightTheme, // Applying the theme
      home: const HomePage(), // Home page as the initial screen
    );
  }
}
