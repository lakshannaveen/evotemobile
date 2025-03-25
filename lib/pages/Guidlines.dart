import 'package:flutter/material.dart';

class GuidelinePage extends StatelessWidget {
  const GuidelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote Guidelines'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added scroll view
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('How to Vote'),
              _buildGuidelineItem(
                  Icons.how_to_vote, 'Ensure you are a registered voter.'),
              _buildGuidelineItem(Icons.login_rounded,
                  'Use the scratch card to fill the login form'),
              _buildGuidelineItem(
                  Icons.lock, 'Log in using your unique voter credentials.'),
              _buildGuidelineItem(
                  Icons.person, 'Select your preferred candidate.'),
              _buildGuidelineItem(
                  Icons.visibility, 'Review your selection before submitting.'),
              _buildGuidelineItem(
                  Icons.send, 'Submit your vote and wait for confirmation.'),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              _buildSectionTitle('Important Notes'),
              _buildGuidelineItem(Icons.verified, 'Your vote is confidential.'),
              _buildGuidelineItem(Icons.warning, 'You can only vote once.'),
              _buildGuidelineItem(
                  Icons.wifi, 'Ensure you have a stable internet connection.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildGuidelineItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
