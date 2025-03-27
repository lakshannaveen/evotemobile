import 'package:flutter/material.dart';
import 'package:evoteapp/services/admin_dashboard_service.dart';
import 'package:evoteapp/pages/election_not_active_page.dart';
import 'package:evoteapp/services/theme_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Sri Lanka Evote System',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => _checkElectionStatusForVoting(context),
                child: const Text('Vote'),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/results'),
                child: const Text('Results'),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/contactus'),
                child: const Text('Contact Us'),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/guidelines'),
                child: const Text('Guideline'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Vote'),
            onTap: () {
              Navigator.pop(context);
              _checkElectionStatusForVoting(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Results'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/results');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Guidelines'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/guidelines');
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contactus');
            },
          ),
          const Divider(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _checkElectionStatusForVoting(BuildContext context) {
    final AdminDashboardService dashboardService = AdminDashboardService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    dashboardService.getElectionStatus().first.then((electionData) {
      Navigator.pop(context);
      final isActive = electionData['isActive'] as bool;
      final status = electionData['status'] as String;

      isActive
          ? Navigator.pushNamed(context, '/votelogin')
          : Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ElectionNotActivePage(status: status),
        ),
      );
    });
  }
}