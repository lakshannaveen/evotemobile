import 'package:flutter/material.dart';
import 'package:evoteapp/config/theme.dart';
import 'package:evoteapp/services/voter_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evoteapp/pages/admin_dashboard_page.dart';

class ManageVotersPage extends StatefulWidget {
  const ManageVotersPage({super.key});

  @override
  ManageVotersPageState createState() => ManageVotersPageState();
}

class ManageVotersPageState extends State<ManageVotersPage> {
  final TextEditingController _searchController = TextEditingController();
  final VoterService _voterService = VoterService();
  List<Map<String, dynamic>> _filteredVoters = [];

  @override
  void initState() {
    super.initState();
  }

  void _addVoter() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: _VoterFormDialog(
          onSubmit: (voter) async {
            try {
              await _voterService.addVoter(voter);
              if (mounted && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voter added successfully')),
                );
              }
            } catch (e) {
              if (mounted && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding voter: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _editVoter(QueryDocumentSnapshot voter) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: _VoterFormDialog(
          initialValue: voter.data() as Map<String, dynamic>,
          onSubmit: (updatedVoter) async {
            try {
              await _voterService.updateVoter(voter.id, updatedVoter);
              if (mounted && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voter updated successfully')),
                );
              }
            } catch (e) {
              if (mounted && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating voter: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _deleteVoter(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Voter'),
        content: const Text('Are you sure you want to delete this voter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Close the dialog first
                Navigator.of(dialogContext).pop();
                await _voterService.deleteVoter(id);
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voter deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting voter: $e')),
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

  Future<void> _filterVoters(String query) async {
    try {
      if (query.isEmpty) {
        setState(() {
          _filteredVoters = [];
        });
        return;
      }
      final results = await _voterService.searchVoters(query);
      if (mounted) {
        setState(() {
          _filteredVoters = results.map((doc) => {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching voters: $e')),
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
          title: const Text('Manage Voters'),
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
                  labelText: 'Search voters by exact NIC or name',
                  hintText: 'Enter complete NIC number or full name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _filterVoters(value.toLowerCase()),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _voterService.getVoters(),
                    builder: (context, snapshot) {
                      final voterCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return Text(
                        'Voters ($voterCount)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: _addVoter,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Voter'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _voterService.getVoters(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final voters = _searchController.text.isEmpty
                        ? snapshot.data!.docs
                        : _filteredVoters;

                    if (voters.isEmpty) {
                      return const Center(child: Text('No voters found'));
                    }

                    return ListView.builder(
                      itemCount: voters.length,
                      itemBuilder: (context, index) {
                        final dynamic voter = voters[index];
                        final Map<String, dynamic> data;
                        final String voterId;

                        if (_searchController.text.isEmpty) {
                          final doc = voter as QueryDocumentSnapshot;
                          data = doc.data() as Map<String, dynamic>;
                          voterId = doc.id;
                        } else {
                          data = voter as Map<String, dynamic>;
                          voterId = data['id'] as String;
                        }
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ExpansionTile(
                            title: Text(data['name'] ?? 'N/A'),
                            subtitle: Text('NIC: ${data['nic'] ?? 'N/A'}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Address: ${data['address'] ?? 'N/A'}'),
                                    Text('Voter ID: ${data['voterId'] ?? 'N/A'}'),
                                    Text('District: ${data['district'] ?? 'N/A'}'),
                                    Text('Polling Division: ${data['pollingDivision'] ?? 'N/A'}'),
                                    Text('Vote Status: ${data['voteStatus'] == true ? 'Voted' : 'Not Voted'}'),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            if (_searchController.text.isEmpty) {
                                              _editVoter(voter as QueryDocumentSnapshot);
                                            } else {
                                              final originalDoc = snapshot.data!.docs
                                                  .firstWhere((doc) => doc.id == voterId);
                                              _editVoter(originalDoc);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteVoter(voterId),
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

class _VoterFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialValue;
  final Function(Map<String, dynamic>) onSubmit;

  const _VoterFormDialog({
    this.initialValue,
    required this.onSubmit,
  });

  @override
  _VoterFormDialogState createState() => _VoterFormDialogState();
}

class _VoterFormDialogState extends State<_VoterFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _nicController;
  late TextEditingController _voterIdController;
  late TextEditingController _districtController;
  late TextEditingController _pollingDivisionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue?['name'] ?? '');
    _addressController = TextEditingController(text: widget.initialValue?['address'] ?? '');
    _nicController = TextEditingController(text: widget.initialValue?['nic'] ?? '');
    _voterIdController = TextEditingController(text: widget.initialValue?['voterId'] ?? '');
    _districtController = TextEditingController(text: widget.initialValue?['district'] ?? '');
    _pollingDivisionController = TextEditingController(text: widget.initialValue?['pollingDivision'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _nicController.dispose();
    _voterIdController.dispose();
    _districtController.dispose();
    _pollingDivisionController.dispose();
    super.dispose();
  }

  bool isValidNIC(String nic) {
    final oldNICRegex = RegExp(r'^[0-9]{9}[vV]$');
    final newNICRegex = RegExp(r'^[0-9]{12}$');
    return oldNICRegex.hasMatch(nic) || newNICRegex.hasMatch(nic);
  }

  bool isValidVoterId(String voterId) {
    final voterIdRegex = RegExp(r'^\d{2}-\d{2}-\d{5}$');
    return voterIdRegex.hasMatch(voterId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: Text(widget.initialValue == null ? 'Add Voter' : 'Edit Voter'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nicController,
                  decoration: const InputDecoration(
                    labelText: 'NIC Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the NIC number';
                    }
                    if (!isValidNIC(value)) {
                      return 'Invalid NIC format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _voterIdController,
                  decoration: const InputDecoration(
                    labelText: 'Voter ID',
                    border: OutlineInputBorder(),
                    hintText: '20-01-12345',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the voter ID';
                    }
                    if (!isValidVoterId(value)) {
                      return 'Invalid voter ID format (YY-DD-NNNNN)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _districtController,
                  decoration: const InputDecoration(
                    labelText: 'District',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the district';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pollingDivisionController,
                  decoration: const InputDecoration(
                    labelText: 'Polling Division',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the polling division';
                    }
                    return null;
                  },
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
                widget.onSubmit({
                  'name': _nameController.text.toLowerCase(),
                  'address': _addressController.text,
                  'nic': _nicController.text.toLowerCase(),
                  'voterId': _voterIdController.text,
                  'district': _districtController.text,
                  'pollingDivision': _pollingDivisionController.text,
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
