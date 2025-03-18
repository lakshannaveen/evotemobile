import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class CastPage extends StatefulWidget {
  const CastPage({super.key});

  @override
  _CastPageState createState() => _CastPageState();
}

class _CastPageState extends State<CastPage> {
  String? _selectedCandidate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cast Your Vote')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select a Candidate',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('candidates')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final candidates = snapshot.data?.docs ?? [];

                if (candidates.isEmpty) {
                  return const Center(child: Text('No candidates available'));
                }

                return ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final candidate =
                        candidates[index].data() as Map<String, dynamic>;

                    Uint8List? imageBytes;
                    if (candidate['partyLogo'] != null) {
                      try {
                        imageBytes = Uri.parse(candidate['partyLogo'])
                            .data
                            ?.contentAsBytes();
                      } catch (e) {
                        debugPrint('Error parsing image: $e');
                      }
                    }

                    return RadioListTile<String>(
                      title: Row(
                        children: [
                          if (imageBytes != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Image.memory(imageBytes,
                                  width: 40, height: 40, fit: BoxFit.contain),
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(candidate['nameSinhala'] ?? 'N/A'),
                              Text(candidate['nameEnglish'] ?? 'N/A'),
                              Text(candidate['nameTamil'] ?? 'N/A'),
                            ],
                          ),
                        ],
                      ),
                      value: candidates[index].id,
                      groupValue: _selectedCandidate,
                      onChanged: (value) {
                        setState(() {
                          _selectedCandidate = value;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
