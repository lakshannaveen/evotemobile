import 'package:flutter/material.dart';

class VerifyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voter ID: ${user['voterId']}',
                style: const TextStyle(fontSize: 18)),
            Text('Name: ${user['name']}', style: const TextStyle(fontSize: 18)),
            Text('NIC: ${user['nic']}', style: const TextStyle(fontSize: 18)),
            Text('District: ${user['district']}',
                style: const TextStyle(fontSize: 18)),
            Text('Polling Division: ${user['pollingDivision']}',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
