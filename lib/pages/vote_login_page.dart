import 'package:flutter/material.dart';

class VoteLoginPage extends StatefulWidget {
  const VoteLoginPage({super.key});

  @override
  VoteLoginPageState createState() => VoteLoginPageState(); // Remove underscore
}

class VoteLoginPageState extends State<VoteLoginPage> {
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _adminTapCount = 0;
  static const String adminSecret = "admin123"; // Admin Secret Key

  @override
  void dispose() {
    _nicController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isValidNIC(String nic) {
    final oldNICRegex =
        RegExp(r'^[0-9]{9}[vV]$'); // Old NIC format (e.g., 123456789V)
    final newNICRegex =
        RegExp(r'^[0-9]{12}$'); // New NIC format (e.g., 200012345678)
    return oldNICRegex.hasMatch(nic) || newNICRegex.hasMatch(nic);
  }

  bool isValidPassword(String password) {
    final passwordRegex =
        RegExp(r'^\d{2}-\d{2}-\d{5}$'); // Password format 20-10-12345
    return passwordRegex.hasMatch(password);
  }

  void _submit() {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('NIC and Password are valid. Proceeding...')),
      );
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
                  'Enter your NIC',
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
                  'Enter your ID',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: 'Enter your ID',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  } else if (!isValidPassword(value)) {
                    return 'Enter a valid password';
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
