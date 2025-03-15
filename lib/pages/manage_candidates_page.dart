import 'package:flutter/material.dart';
import 'package:evoteapp/config/theme.dart';
import 'package:evoteapp/services/candidate_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evoteapp/pages/admin_dashboard_page.dart';
import 'package:file_picker/file_picker.dart';

class ManageCandidatesPage extends StatefulWidget {
  const ManageCandidatesPage({super.key});

  @override
  ManageCandidatesPageState createState() => ManageCandidatesPageState();
}

class ManageCandidatesPageState extends State<ManageCandidatesPage> {
  final TextEditingController _searchController = TextEditingController();
  final CandidateService _candidateService = CandidateService();
  List<Map<String, dynamic>> _filteredCandidates = [];

  @override
  void initState() {
    super.initState();
  }

  void _addCandidate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: _CandidateFormDialog(
          onSubmit: (candidate) async {
            try {
              await _candidateService.addCandidate(candidate);
              if (mounted && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Candidate added successfully')),
                );
              }
            } catch (e) {
              if (mounted && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding candidate: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _editCandidate(QueryDocumentSnapshot candidate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: _CandidateFormDialog(
          initialValue: candidate.data() as Map<String, dynamic>,
          onSubmit: (updatedCandidate) async {
            try {
              await _candidateService.updateCandidate(candidate.id, updatedCandidate);
              if (mounted && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Candidate updated successfully')),
                );
              }
            } catch (e) {
              if (mounted && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating candidate: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _deleteCandidate(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Candidate'),
        content: const Text('Are you sure you want to delete this candidate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.of(dialogContext).pop();
                await _candidateService.deleteCandidate(id);
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Candidate deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting candidate: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _filterCandidates(String query) async {
    try {
      if (query.isEmpty) {
        setState(() {
          _filteredCandidates = [];
        });
        return;
      }
      final results = await _candidateService.searchCandidates(query);
      if (mounted) {
        setState(() {
          _filteredCandidates = results.map((doc) => {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching candidates: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.adminTheme,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardPage(),
              ),
            ),
          ),
          title: const Text('Manage Candidates'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search candidates by name',
                  hintText: 'Search in any language',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _filterCandidates(value.toLowerCase()),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _candidateService.getCandidates(),
                    builder: (context, snapshot) {
                      final candidateCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return Text(
                        'Candidates ($candidateCount)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: _addCandidate,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Candidate'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _candidateService.getCandidates(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final candidates = _searchController.text.isEmpty
                        ? snapshot.data!.docs
                        : _filteredCandidates;

                    if (candidates.isEmpty) {
                      return const Center(child: Text('No candidates found'));
                    }

                    return ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final dynamic candidate = candidates[index];
                        final Map<String, dynamic> data;
                        final String candidateId;

                        if (_searchController.text.isEmpty) {
                          final doc = candidate as QueryDocumentSnapshot;
                          data = doc.data() as Map<String, dynamic>;
                          candidateId = doc.id;
                        } else {
                          data = candidate as Map<String, dynamic>;
                          candidateId = data['id'] as String;
                        }
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ExpansionTile(
                            leading: data['partyLogo'] != null
                                ? SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.memory(
                                      Uri.parse(data['partyLogo']).data!.contentAsBytes(),
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : const Icon(Icons.person),
                            title: Text(data['nameEnglish'] ?? 'N/A'),
                            subtitle: Text(data['nameSinhala'] ?? 'N/A'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name (English): ${data['nameEnglish'] ?? 'N/A'}'),
                                    Text('Name (Sinhala): ${data['nameSinhala'] ?? 'N/A'}'),
                                    Text('Name (Tamil): ${data['nameTamil'] ?? 'N/A'}'),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            if (_searchController.text.isEmpty) {
                                              _editCandidate(candidate as QueryDocumentSnapshot);
                                            } else {
                                              final originalDoc = snapshot.data!.docs
                                                  .firstWhere((doc) => doc.id == candidateId);
                                              _editCandidate(originalDoc);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteCandidate(candidateId),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CandidateFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialValue;
  final Function(Map<String, dynamic>) onSubmit;

  const _CandidateFormDialog({
    this.initialValue,
    required this.onSubmit,
  });

  @override
  _CandidateFormDialogState createState() => _CandidateFormDialogState();
}

class _CandidateFormDialogState extends State<_CandidateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameEnglishController;
  late TextEditingController _nameSinhalaController;
  late TextEditingController _nameTamilController;
  String? _partyLogo;

  @override
  void initState() {
    super.initState();
    _nameEnglishController = TextEditingController(text: widget.initialValue?['nameEnglish'] ?? '');
    _nameSinhalaController = TextEditingController(text: widget.initialValue?['nameSinhala'] ?? '');
    _nameTamilController = TextEditingController(text: widget.initialValue?['nameTamil'] ?? '');
    _partyLogo = widget.initialValue?['partyLogo'];
  }

  @override
  void dispose() {
    _nameEnglishController.dispose();
    _nameSinhalaController.dispose();
    _nameTamilController.dispose();
    super.dispose();
  }

  Future<void> _pickPartyLogo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['svg'],
      );

      if (result != null) {
        setState(() {
          _partyLogo = Uri.dataFromBytes(
            result.files.first.bytes!,
            mimeType: 'image/svg+xml'
          ).toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking logo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: Text(widget.initialValue == null ? 'Add Candidate' : 'Edit Candidate'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameEnglishController,
                  decoration: const InputDecoration(
                    labelText: 'Name (English)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name in English';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameSinhalaController,
                  decoration: const InputDecoration(
                    labelText: 'Name (Sinhala)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name in Sinhala';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameTamilController,
                  decoration: const InputDecoration(
                    labelText: 'Name (Tamil)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name in Tamil';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickPartyLogo,
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Party Logo (SVG)'),
                      ),
                    ),
                    if (_partyLogo != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _partyLogo = null),
                      ),
                    ],
                  ],
                ),
                if (_partyLogo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.memory(
                        Uri.parse(_partyLogo!).data!.contentAsBytes(),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_partyLogo == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please upload a party logo')),
                  );
                  return;
                }
                widget.onSubmit({
                  'nameEnglish': _nameEnglishController.text.toLowerCase(),
                  'nameSinhala': _nameSinhalaController.text,
                  'nameTamil': _nameTamilController.text,
                  'partyLogo': _partyLogo,
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}