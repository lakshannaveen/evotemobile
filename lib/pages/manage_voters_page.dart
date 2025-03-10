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
      'address': '123 Temple Road, Colombo 03',
      'nic': '199912345678',
      'voterId': '20-01-12345',
      'district': 'Colombo',
      'pollingDivision': 'Colombo Central',
      'voteStatus': false
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'address': '45 Galle Road, Dehiwala',
      'nic': '200012345678',
      'voterId': '20-02-12346',
      'district': 'Colombo',
      'pollingDivision': 'Dehiwala',
      'voteStatus': false
    },
    {
      'id': '3',
      'name': 'Robert Johnson',
      'address': '789 Kandy Road, Kandy',
      'nic': '199812345678',
      'voterId': '20-03-12347',
      'district': 'Kandy',
      'pollingDivision': 'Kandy Central',
      'voteStatus': false
    },
    {
      'id': '4',
      'name': 'Emily Davis',
      'address': '101 Gampaha Road, Gampaha',
      'nic': '199712345678',
      'voterId': '20-04-12348',
      'district': 'Gampaha',
      'pollingDivision': 'Gampaha Central',
      'voteStatus': false
    },
    {
      'id': '5',
      'name': 'Michael Wilson',
      'address': '202 Matara Road, Matara',
      'nic': '199612345678',
      'voterId': '20-05-12349',
      'district': 'Matara',
      'pollingDivision': 'Matara Central',
      'voteStatus': false
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
              ...voter,
              'voteStatus': false,
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
                ...updatedVoter,
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
          final searchQuery = query.toLowerCase();
          return voter['name'].toString().toLowerCase().contains(searchQuery) ||
              voter['nic'].toString().toLowerCase().contains(searchQuery) ||
              voter['voterId'].toString().toLowerCase().contains(searchQuery) ||
              voter['district'].toString().toLowerCase().contains(searchQuery) ||
              voter['pollingDivision'].toString().toLowerCase().contains(searchQuery);
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
                            child: ExpansionTile(
                              title: Text(voter['name']),
                              subtitle: Text('NIC: ${voter['nic']}'),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Address: ${voter['address']}'),
                                      Text('Voter ID: ${voter['voterId']}'),
                                      Text('District: ${voter['district']}'),
                                      Text('Polling Division: ${voter['pollingDivision']}'),
                                      Text('Vote Status: ${voter['voteStatus'] ? 'Voted' : 'Not Voted'}'),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
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
                                    ],
                                  ),
                                ),
                              ],
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
    return AlertDialog(
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
                'name': _nameController.text,
                'address': _addressController.text,
                'nic': _nicController.text,
                'voterId': _voterIdController.text,
                'district': _districtController.text,
                'pollingDivision': _pollingDivisionController.text,
              });
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
