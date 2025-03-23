import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id; // Firestore document ID
  String userId; // The voter ID (e.g. 20-03-12348)
  String fullName;
  String address;
  String nic;
  bool voteStatus;
  String district;
  String pollingDivision;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.address,
    required this.nic,
    required this.voteStatus,
    required this.district,
    required this.pollingDivision,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'voterId': userId, // Store as voterId in Firestore
      'name': fullName,
      'address': address,
      'nic': nic,
      'voteStatus': voteStatus,
      'district': district,
      'pollingDivision': pollingDivision,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String docId) {
    return User(
      id: docId,
      userId: map['voterId'] ?? '', // Read from voterId field
      fullName: map['name'] ?? '',
      address: map['address'] ?? '',
      nic: map['nic'] ?? '',
      voteStatus: map['voteStatus'] ?? false,
      district: map['district'] ?? '',
      pollingDivision: map['pollingDivision'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
