import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import '../services/candidate_service.dart';

class CastPage extends StatefulWidget {
  const CastPage({super.key});

  @override
  _CastPageState createState() => _CastPageState();
}

class _CastPageState extends State<CastPage> {
  final CandidateService _candidateService = CandidateService();

  /// Use ValueNotifier instead of setState
  final ValueNotifier<String?> _selectedCandidate =
      ValueNotifier<String?>(null);

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
              stream: _candidateService.getCandidates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: \${snapshot.error}'));
                }

                final candidates = snapshot.data?.docs ?? [];

                if (candidates.isEmpty) {
                  return const Center(child: Text('No candidates available'));
                }

                return _buildCandidateList(candidates);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_selectedCandidate.value != null) {
                  // Submit vote logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Vote submitted for candidate ID: \${_selectedCandidate.value}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please select a candidate before submitting.')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateList(List<QueryDocumentSnapshot> candidates) {
    return ListView.builder(
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final candidate = candidates[index].data() as Map<String, dynamic>;

        Uint8List? imageBytes;
        if (candidate['partyLogo'] != null) {
          try {
            imageBytes =
                Uri.parse(candidate['partyLogo']).data?.contentAsBytes();
          } catch (e) {
            debugPrint('Error parsing image: $e');
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Party Logo on the left
              if (imageBytes != null)
                Image.memory(imageBytes,
                    width: 50, height: 50, fit: BoxFit.contain),

              const SizedBox(width: 16),

              // Candidate Names (Centered)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(candidate['nameSinhala'] ?? 'N/A',
                        textAlign: TextAlign.center),
                    Text(candidate['nameEnglish'] ?? 'N/A',
                        textAlign: TextAlign.center),
                    Text(candidate['nameTamil'] ?? 'N/A',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),

              // Radio Button on the right
              ValueListenableBuilder<String?>(
                valueListenable: _selectedCandidate,
                builder: (context, selected, child) {
                  return Radio<String>(
                    value: candidates[index].id,
                    groupValue: selected,
                    onChanged: (value) {
                      if (value != null) {
                        _selectedCandidate.value = value;
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
