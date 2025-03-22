import 'package:flutter/material.dart';
import 'package:evoteapp/config/theme.dart';
import 'package:evoteapp/services/candidate_service.dart';
import 'package:evoteapp/models/candidate.dart';
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
  List<Candidate> _filteredCandidates = [];

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

  void _editCandidate(Candidate candidate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: _CandidateFormDialog(
          initialValue: candidate,
          onSubmit: (updatedCandidate) async {
            try {
              await _candidateService.updateCandidate(candidate.id!, updatedCandidate);
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
          _filteredCandidates = results;
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
                  StreamBuilder<List<Candidate>>(
                    stream: _candidateService.getCandidates(),
                    builder: (context, snapshot) {
                      final candidateCount = snapshot.hasData ? snapshot.data!.length : 0;
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
                child: StreamBuilder<List<Candidate>>(
                  stream: _candidateService.getCandidates(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final candidates = _searchController.text.isEmpty
                        ? snapshot.data!
                        : _filteredCandidates;

                    if (candidates.isEmpty) {
                      return const Center(child: Text('No candidates found'));
                    }

                    return ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = candidates[index];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ExpansionTile(
                            leading: candidate.partyLogo.isNotEmpty
                                ? SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.memory(
                                      Uri.parse(candidate.partyLogo).data!.contentAsBytes(),
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : const Icon(Icons.person),
                            title: Text(candidate.nameEnglish),
                            subtitle: Text(candidate.nameSinhala),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name (English): ${candidate.nameEnglish}'),
                                    Text('Name (Sinhala): ${candidate.nameSinhala}'),
                                    Text('Name (Tamil): ${candidate.nameTamil}'),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editCandidate(candidate),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteCandidate(candidate.id!),
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
  final Candidate? initialValue;
  final Function(Candidate) onSubmit;

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
    _nameEnglishController = TextEditingController(text: widget.initialValue?.nameEnglish ?? '');
    _nameSinhalaController = TextEditingController(text: widget.initialValue?.nameSinhala ?? '');
    _nameTamilController = TextEditingController(text: widget.initialValue?.nameTamil ?? '');
    _partyLogo = widget.initialValue?.partyLogo;
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
        allowedExtensions: ['png', 'jpg', 'jpeg', 'svg', 'webp', 'gif'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        final String mimeType = switch (result.files.first.extension?.toLowerCase()) {
          'svg' => 'image/svg+xml',
          'png' => 'image/png',
          'jpg' => 'image/jpeg',
          'jpeg' => 'image/jpeg',
          'webp' => 'image/webp',
          'gif' => 'image/gif',
          _ => 'image/png'
        };
        
        setState(() {
          _partyLogo = Uri.dataFromBytes(
            result.files.first.bytes!,
            mimeType: mimeType
          ).toString();
        });
      } else {
        throw 'No file selected or file is empty';
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
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  widget.initialValue == null ? 'Add Candidate' : 'Edit Candidate',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Section
                        const Text(
                          'Candidate Names',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameEnglishController,
                          decoration: const InputDecoration(
                            labelText: 'Name (English)',
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
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
                            fillColor: Colors.white,
                            filled: true,
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
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the name in Tamil';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Party Logo Section
                        const Text(
                          'Party Logo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _pickPartyLogo,
                                      icon: const Icon(Icons.upload),
                                      label: const Text('Upload Party Logo'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        backgroundColor: Colors.redAccent,
                                      ),
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
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Image.memory(
                                      Uri.parse(_partyLogo!).data!.contentAsBytes(),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_partyLogo == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please upload a party logo')),
                          );
                          return;
                        }
                        widget.onSubmit(
                          Candidate(
                            nameEnglish: _nameEnglishController.text,
                            nameSinhala: _nameSinhalaController.text,
                            nameTamil: _nameTamilController.text,
                            partyLogo: _partyLogo!,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}