import 'package:flutter/material.dart';
import '../services/candidate_service.dart';
import '../services/vote_submission_service.dart';
import '../models/candidate.dart';
import 'dart:typed_data';

class CastPage extends StatefulWidget {
  const CastPage({super.key});

  @override
  _CastPageState createState() => _CastPageState();
}

class _CastPageState extends State<CastPage> {
  final CandidateService _candidateService = CandidateService();
  final VoteSubmissionService _voteService = VoteSubmissionService();

  final ValueNotifier<String?> _selectedCandidate =
      ValueNotifier<String?>(null);
  late String nic;
  late String voterId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    nic = args['nic'];
    voterId = args['voterId'];
  }

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
            child: StreamBuilder<List<Candidate>>(
              stream: _candidateService.getCandidates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final candidates = snapshot.data ?? [];
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
              onPressed: () async {
                if (_selectedCandidate.value != null) {
                  final result = await _voteService.submitVote(
                    nic,
                    voterId,
                    _selectedCandidate.value!,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result!)),
                  );

                  if (result == 'Vote submitted successfully') {
                    // Optionally, navigate or update UI if needed
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please select a candidate before submitting.'),
                    ),
                  );
                }
              },
              child: const Text('Submit Vote'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateList(List<Candidate> candidates) {
    return ListView.builder(
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        Uint8List? imageBytes;

        if (candidate.partyLogo.isNotEmpty) {
          try {
            imageBytes = Uri.parse(candidate.partyLogo).data?.contentAsBytes();
          } catch (e) {
            debugPrint('Error parsing image: $e');
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (imageBytes != null)
                  Image.memory(imageBytes,
                      width: 50, height: 50, fit: BoxFit.contain),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(candidate.nameSinhala, textAlign: TextAlign.center),
                      Text(candidate.nameEnglish, textAlign: TextAlign.center),
                      Text(candidate.nameTamil, textAlign: TextAlign.center),
                    ],
                  ),
                ),
                ValueListenableBuilder<String?>(
                  valueListenable: _selectedCandidate,
                  builder: (context, selected, _) {
                    return Radio<String>(
                      value: candidate.id!,
                      groupValue: selected,
                      onChanged: (value) {
                        _selectedCandidate.value = value;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
