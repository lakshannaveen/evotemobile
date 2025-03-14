class User {
  String userId;
  String fullName;
  String address;
  String nic; // Single NIC field
  bool voteStatus; // Changed to bool
  String district;
  String pollingDivision;

  User({
    required this.userId,
    required this.fullName,
    required this.address,
    required this.nic,
    required this.voteStatus,
    required this.district,
    required this.pollingDivision,
  });

  Map<String, dynamic> toMap() {
    return {
      'voterId': userId, // Matches Firestore
      'name': fullName,
      'address': address,
      'nic': nic,
      'voteStatus': voteStatus,
      'district': district,
      'pollingDivision': pollingDivision,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['voterId'],
      fullName: map['name'],
      address: map['address'],
      nic: map['nic'],
      voteStatus: map['voteStatus'],
      district: map['district'],
      pollingDivision: map['pollingDivision'],
    );
  }
}
