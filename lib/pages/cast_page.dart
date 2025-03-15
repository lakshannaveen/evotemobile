import 'package:flutter/material.dart';

class CastPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cast Your Vote')),
      body: Center(
        child: const Text(
          'Welcome to cast your vote!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
