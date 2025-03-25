import 'package:flutter/material.dart';
import 'package:evoteapp/services/admin_dashboard_service.dart';
import 'package:evoteapp/pages/election_not_active_page.dart';

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
                  // Check election status before going to vote page
                  _checkElectionStatusForVoting(context);
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
            const SizedBox(height: 30),
            SizedBox(
              width: 200, // Adjust button width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/contactus');
                },
                child: const Text('Contact Us'),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/guidlines');
                },
                child: const Text('Guideline'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Method to check election status before allowing voting
  void _checkElectionStatusForVoting(BuildContext context) {
    final AdminDashboardService dashboardService = AdminDashboardService();
    
    // Show loading dialog while checking
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    // Get the election status once
    dashboardService.getElectionStatus().first.then((electionData) {
      // Close loading dialog
      Navigator.pop(context);
      
      final isActive = electionData['isActive'] as bool;
      final status = electionData['status'] as String;
      
      if (isActive) {
        // If election is active, proceed to vote login page
        Navigator.pushNamed(context, '/votelogin');
      } else {
        // If not active, show the election not active page
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => ElectionNotActivePage(status: status),
          ),
        );
      }
    });
  }
}
