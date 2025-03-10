import 'package:flutter/material.dart';
import 'package:evoteapp/config/theme.dart';

class ManageVotersPage extends StatefulWidget {
  const ManageVotersPage({super.key});

  @override
  ManageVotersPageState createState() => ManageVotersPageState();
}

class ManageVotersPageState extends State<ManageVotersPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _voters = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'voterId': 'VOT001'
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'voterId': 'VOT002'
    },
    {
      'id': '3',
      'name': 'Robert Johnson',
      'email': 'robert.j@example.com',
      'voterId': 'VOT003'
    },
    {
      'id': '4',
      'name': 'Emily Davis',
      'email': 'emily.d@example.com',
      'voterId': 'VOT004'
    },
    {
      'id': '5',
      'name': 'Michael Wilson',
      'email': 'michael.w@example.com',
      'voterId': 'VOT005'
    },
  ];
  List<Map<String, dynamic>> _filteredVoters = [];

  @override
  void initState() {
    super.initState();
    _filteredVoters = _voters;
  }

  void _addVoter() {
    showDialog(
      context: context,
      builder: (context) => _VoterFormDialog(
        onSubmit: (voter) {
          setState(() {
            _voters.add({
              'id': '${_voters.length + 1}',
              'name': voter['name'],
              'email': voter['email'],
              'voterId':
                  'VOT${(_voters.length + 1).toString().padLeft(3, '0')}',
            });
            _filterVoters(_searchController.text);
          });
        },
      ),
    );
  }

  void _editVoter(Map<String, dynamic> voter) {
    showDialog(
      context: context,
      builder: (context) => _VoterFormDialog(
        initialValue: voter,
        onSubmit: (updatedVoter) {
          setState(() {
            final index = _voters.indexWhere((v) => v['id'] == voter['id']);
            if (index != -1) {
              _voters[index] = {
                ..._voters[index],
                'name': updatedVoter['name'],
                'email': updatedVoter['email'],
              };
              _filterVoters(_searchController.text);
            }
          });
        },
      ),
    );
  }

  void _deleteVoter(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Voter'),
        content: const Text('Are you sure you want to delete this voter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _voters.removeWhere((voter) => voter['id'] == id);
                _filterVoters(_searchController.text);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _filterVoters(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVoters = _voters;
      } else {
        _filteredVoters = _voters.where((voter) {
          final name = voter['name'].toString().toLowerCase();
          final email = voter['email'].toString().toLowerCase();
          final voterId = voter['voterId'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();

          return name.contains(searchQuery) ||
              email.contains(searchQuery) ||
              voterId.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.adminTheme,
      child: Scaffold(
        appBar: AppBar(
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
                  labelText: 'Search voters',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _filterVoters,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voters (${_filteredVoters.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                child: _filteredVoters.isEmpty
                    ? const Center(
                        child: Text('No voters found'),
                      )
                    : ListView.builder(
                        itemCount: _filteredVoters.length,
                        itemBuilder: (context, index) {
                          final voter = _filteredVoters[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              title: Text(voter['name']),
                              subtitle: Text(
                                  '${voter['email']} • ID: ${voter['voterId']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editVoter(voter),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteVoter(voter['id']),
                                  ),
                                ],
                              ),
                            ),
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
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialValue?['name'] ?? '');
    _emailController =
        TextEditingController(text: widget.initialValue?['email'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialValue == null ? 'Add Voter' : 'Edit Voter'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit({
                'name': _nameController.text,
                'email': _emailController.text,
              });
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.initialValue == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
