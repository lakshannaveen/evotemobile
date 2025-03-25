import 'package:flutter/material.dart';
import 'package:evoteapp/config/theme.dart';

class ElectionNotActivePage extends StatelessWidget {
  final String status;
  
  const ElectionNotActivePage({
    super.key, 
    this.status = 'Not Started'
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sri Lanka eVote System'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Election status icon
              Icon(
                status == 'Ended' ? Icons.how_to_vote_outlined : Icons.access_time_rounded,
                size: 80,
                color: status == 'Ended' ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 30),
              
              // Status text
              Text(
                status == 'Ended' 
                    ? 'Election Has Ended'
                    : 'Election Has Not Started Yet',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description text
              Text(
                status == 'Ended'
                    ? 'Thank you for your participation. The election voting period has concluded.'
                    : 'Please check back later when the election is open for voting.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Access results if election has ended
              if (status == 'Ended')
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/results');
                    },
                    child: const Text('View Results'),
                  ),
                ),
              
              // Always show contact us
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/contactus');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Contact Us'),
                ),
              ),
              
              // Always show guidelines
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/guidlines');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Guidelines'),
                ),
              ),
              
              // Admin access
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin');
                },
                child: const Text('Admin Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}