import 'package:flutter/material.dart';

class VerifyPage extends StatelessWidget {
  const VerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Verify Page')), // Centered title
        automaticallyImplyLeading: false, // Removes the back icon
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Centering the user info in a table format
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Text('Voter ID:',
                            style: TextStyle(fontSize: 18)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(user['voterId'],
                            style: const TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                        ),
                        child:
                            const Text('Name:', style: TextStyle(fontSize: 18)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(user['name'],
                            style: const TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                        ),
                        child:
                            const Text('NIC:', style: TextStyle(fontSize: 18)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(user['nic'],
                            style: const TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Text('District:',
                            style: TextStyle(fontSize: 18)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(user['district'],
                            style: const TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Text('Polling Division:',
                            style: TextStyle(fontSize: 18)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(user['pollingDivision'],
                            style: const TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Link to Contact Us
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/contactus');
                },
                child: const Text('If anything is wrong, contact us.'),
              ),
              const SizedBox(height: 20),

              // Button to go to Vote
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cast');
                },
                child: const Text('Go to Vote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
