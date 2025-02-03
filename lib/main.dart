import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(), // Use a non-const here
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Add functionality for the Results button here
              },
              child: const Text('Results'),
            ),
            const SizedBox(width: 20), // Space between buttons
            ElevatedButton(
              onPressed: () {
                // Add functionality for the Vote button here
              },
              child: const Text('Vote'),
            ),
          ],
        ),
      ),
    );
  }
}
