import 'package:flutter/material.dart';

class CastPage extends StatelessWidget {
  const CastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cast Your Vote')),
      body: const Center(
        child: Text(
          'Welcome to cast your vote!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
