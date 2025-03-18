import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact_us_model.dart';
import '../services/contact_us_service.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicController = TextEditingController();
  final _messageController = TextEditingController();
  final ContactUsService _contactUsService = ContactUsService();

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Contact Us',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final contactUsData = ContactUsModel(
        nic: _nicController.text,
        message: _messageController.text,
      );
      try {
        await _contactUsService.submitContactUsData(contactUsData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data submitted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String phoneNumber =
        '+94 123 456 789'; // Replace with any contact number
    const String email =
        'EvoteContact@gmail.com'; // Replace with any contact email

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      'If you have any questions, please call the following number or send us an email:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _launchPhone(phoneNumber),
                      child: const Text(
                        phoneNumber,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _launchEmail(email),
                      child: const Text(
                        email,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nicController,
                            decoration: const InputDecoration(labelText: 'NIC'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your NIC';
                              }
                              // Add NIC validation logic here
                              final nicPattern =
                                  RegExp(r'^[0-9]{9}[vVxX]|[0-9]{12}$');
                              if (!nicPattern.hasMatch(value)) {
                                return 'Please enter a valid NIC';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _messageController,
                            decoration:
                                const InputDecoration(labelText: 'Message'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a message';
                              }
                              if (value.length > 250) {
                                return 'Message cannot exceed 250 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
