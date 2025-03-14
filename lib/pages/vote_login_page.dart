import 'package:flutter/material.dart';
import '../services/login_service.dart'; // Import the LoginService

class VoteLoginPage extends StatefulWidget {
  const VoteLoginPage({super.key});

  @override
  VoteLoginPageState createState() => VoteLoginPageState(); // Remove underscore
}

class VoteLoginPageState extends State<VoteLoginPage> {
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _adminTapCount = 0;
  static const String adminSecret = "admin123"; // Admin Secret Key
  final LoginService _loginService = LoginService(); // Initialize LoginService

  @override
  void dispose() {
    _nicController.dispose();
    _idController.dispose();
    super.dispose();
  }

  bool isValidNIC(String nic) {
    final oldNICRegex =
        RegExp(r'^[0-9]{9}[vV]$'); // Old NIC format (e.g., 123456789V)
    final newNICRegex =
        RegExp(r'^[0-9]{12}$'); // New NIC format (e.g., 200012345678)
    return oldNICRegex.hasMatch(nic) || newNICRegex.hasMatch(nic);
  }

  bool isValidUserId(String userId) {
    final userIdRegex = RegExp(r'^\d{2}-\d{2}-\d{5}$'); // Format: 10-20-12345
    return userIdRegex.hasMatch(userId);
  }

  Future<void> _submit() async {
    if (_nicController.text == adminSecret) {
      // If admin secret is entered, increase tap count
      _adminTapCount++;
      if (_adminTapCount >= 5) {
        _adminTapCount = 0; // Reset tap count
        Navigator.pushNamed(context, '/admin'); // Navigate to Admin Page
        return;
      }
    } else {
      _adminTapCount = 0; // Reset if a different NIC is entered
    }

    // Normal user validation
    if (_formKey.currentState!.validate()) {
      final nic = _nicController.text;
      final userId = _idController.text;

      try {
        final user = await _loginService.validateLogin(nic, userId);

        // Debug: Log the user object
        print('User: $user');

        if (user != null) {
          Navigator.pushNamed(context, '/verify',
              arguments: user); // Pass User object to Verify Page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Invalid NIC, User ID, or Vote Status')),
          );
        }
      } catch (e) {
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote Login Page'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter your NIC (Old or New)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _nicController,
                decoration: const InputDecoration(
                  hintText: 'Enter your NIC',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIC cannot be empty';
                  } else if (!isValidNIC(value) && value != adminSecret) {
                    return 'Enter a valid Sri Lankan NIC';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter your User ID',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  hintText: 'Enter your User ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'User ID cannot be empty';
                  } else if (!isValidUserId(value)) {
                    return 'Enter a valid User ID (e.g., 10-20-12345)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
