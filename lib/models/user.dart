class User {
  String userId;
  String fullName;
  String address;
  String nicOld;
  String nicNew;
  int voteStatus;
  String district;
  String pollingDivision;

  // Constructor
  User({
    required this.userId,
    required this.fullName,
    required this.address,
    required this.nicOld,
    required this.nicNew,
    required this.voteStatus,
    required this.district,
    required this.pollingDivision,
  });

  // Convert User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'address': address,
      'nic_old': nicOld,
      'nic_new': nicNew,
      'voteStatus': voteStatus, // Corrected spelling
      'district': district,
      'polling_division': pollingDivision,
    };
  }

  // Convert Map to a User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      fullName: map['full_name'],
      address: map['address'],
      nicOld: map['nic_old'],
      nicNew: map['nic_new'],
      voteStatus: map['voteStatus'], // Corrected spelling
      district: map['district'],
      pollingDivision: map['polling_division'],
    );
  }
}
