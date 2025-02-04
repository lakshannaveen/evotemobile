import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Sri Lanka Evote System',
          style: TextStyle(fontSize: 18), // Adjust font size if needed
        ),
        centerTitle: true, // Center the title
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200, // Adjust button width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/votelogin');
                },
                child: const Text('Vote'),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200, // Adjust button width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/results');
                },
                child: const Text('Results'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
