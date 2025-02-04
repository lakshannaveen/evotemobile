import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Page'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Result Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
