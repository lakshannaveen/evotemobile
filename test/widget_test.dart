import 'package:evoteapp/pages/home_page.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Voting App',
        home: const HomePage() // Ensure HomePage is set as the initial screen
        );
  }
}
