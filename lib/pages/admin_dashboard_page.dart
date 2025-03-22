import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evoteapp/config/theme.dart';
import 'package:evoteapp/pages/manage_voters_page.dart';
import 'package:evoteapp/pages/manage_candidates_page.dart';
import 'package:evoteapp/pages/view_contact_submissions_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  AdminDashboardPageState createState() => AdminDashboardPageState();
}

class AdminDashboardPageState extends State<AdminDashboardPage> {
  int _candidateCount = 0;
  int _voterCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCounts(); // Fetch counts when the page loads
  }

  // Fetch voter and candidate counts from Firestore
  Future<void> _fetchCounts() async {
    try {
      // Get candidates count
      QuerySnapshot candidatesSnapshot =
          await FirebaseFirestore.instance.collection('candidates').get();
      int candidateCount = candidatesSnapshot.docs.length;

      // Get voters count
      QuerySnapshot votersSnapshot =
          await FirebaseFirestore.instance.collection('voters').get();
      int voterCount = votersSnapshot.docs.length;

      // Update state with counts
      setState(() {
        _candidateCount = candidateCount;
        _voterCount = voterCount;
      });
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.adminTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.of(context).pop(); // Sign out action
              },
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome, Admin',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'System Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Display candidate and voter count
              _buildOverviewCard(
                title: 'Registered Candidates',
                value: _candidateCount.toString(),
                icon: Icons.person,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildOverviewCard(
                title: 'Registered Voters',
                value: _voterCount.toString(),
                icon: Icons.people,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Drawer Navigation with Added Settings & Manage Elections
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            child: Text(
              'Admin Controls',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Voters'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageVotersPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Manage Candidates'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageCandidatesPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.how_to_vote),
            title: const Text('Manage Elections'),
            onTap: () {
              // Navigate to Manage Elections Page (Create this page separately)
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to Settings Page (Create this page separately)
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Contact Submissions'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewContactSubmissionsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Reusable Card Widget
  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
