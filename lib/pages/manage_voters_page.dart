import 'package:flutter/material.dart';
import 'package:evoteapp/config/theme.dart';
import 'package:evoteapp/services/voter_service.dart';
import 'package:evoteapp/models/user.dart';
import 'package:evoteapp/pages/admin_dashboard_page.dart';

class ManageVotersPage extends StatefulWidget {
  const ManageVotersPage({super.key});

  @override
  ManageVotersPageState createState() => ManageVotersPageState();
}

class ManageVotersPageState extends State<ManageVotersPage> {
  final TextEditingController _searchController = TextEditingController();
  final VoterService _voterService = VoterService();
  List<User> _filteredVoters = [];

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

  void _editVoter(User voter) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: _VoterFormDialog(
          initialValue: voter,
          onSubmit: (updatedVoter) async {
            try {
              await _voterService.updateVoter(voter.userId, updatedVoter);
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
          _filteredVoters = results;
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
                  StreamBuilder<List<User>>(
                    stream: _voterService.getVoters(),
                    builder: (context, snapshot) {
                      final voterCount = snapshot.hasData ? snapshot.data!.length : 0;
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
                child: StreamBuilder<List<User>>(
                  stream: _voterService.getVoters(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final voters = _searchController.text.isEmpty
                        ? snapshot.data!
                        : _filteredVoters;

                    if (voters.isEmpty) {
                      return const Center(child: Text('No voters found'));
                    }

                    return ListView.builder(
                      itemCount: voters.length,
                      itemBuilder: (context, index) {
                        final voter = voters[index];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ExpansionTile(
                            title: Text(voter.fullName),
                            subtitle: Text('NIC: ${voter.nic}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Address: ${voter.address}'),
                                    Text('Voter ID: ${voter.userId}'),
                                    Text('District: ${voter.district}'),
                                    Text('Polling Division: ${voter.pollingDivision}'),
                                    Text('Vote Status: ${voter.voteStatus ? 'Voted' : 'Not Voted'}'),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editVoter(voter),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteVoter(voter.userId),
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
  final User? initialValue;
  final Function(User) onSubmit;

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
    _nameController = TextEditingController(text: widget.initialValue?.fullName ?? '');
    _addressController = TextEditingController(text: widget.initialValue?.address ?? '');
    _nicController = TextEditingController(text: widget.initialValue?.nic ?? '');
    _voterIdController = TextEditingController(text: widget.initialValue?.userId ?? '');
    _districtController = TextEditingController(text: widget.initialValue?.district ?? '');
    _pollingDivisionController = TextEditingController(text: widget.initialValue?.pollingDivision ?? '');
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
                  widget.initialValue == null ? 'Add Voter' : 'Edit Voter',
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
                        // Personal Information Section
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
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
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Identification Section
                        const Text(
                          'Identification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nicController,
                          decoration: const InputDecoration(
                            labelText: 'NIC Number',
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
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
                            fillColor: Colors.white,
                            filled: true,
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
                        const SizedBox(height: 24),

                        // Location Section
                        const Text(
                          'Voting Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _districtController,
                          decoration: const InputDecoration(
                            labelText: 'District',
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
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
                            fillColor: Colors.white,
                            filled: true,
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
                        widget.onSubmit(
                          User(
                            userId: _voterIdController.text,
                            fullName: _nameController.text,
                            address: _addressController.text,
                            nic: _nicController.text.toLowerCase(),
                            voteStatus: widget.initialValue?.voteStatus ?? false,
                            district: _districtController.text,
                            pollingDivision: _pollingDivisionController.text,
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
