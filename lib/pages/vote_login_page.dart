import 'package:flutter/material.dart';

class VoteLoginPage extends StatelessWidget {
  const VoteLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote Login Page'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Vote Login Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
