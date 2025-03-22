import 'package:cloud_firestore/cloud_firestore.dart';

class Candidate {
  final String? id;
  final String nameEnglish;
  final String nameSinhala;
  final String nameTamil;
  final String partyLogo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Candidate({
    this.id,
    required this.nameEnglish,
    required this.nameSinhala,
    required this.nameTamil,
    required this.partyLogo,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Candidate to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'nameEnglish': nameEnglish.toLowerCase(),
      'nameSinhala': nameSinhala,
      'nameTamil': nameTamil,
      'partyLogo': partyLogo,
    };
  }

  // Create Candidate from Firebase document
  factory Candidate.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Candidate(
      id: doc.id,
      nameEnglish: data['nameEnglish'] ?? '',
      nameSinhala: data['nameSinhala'] ?? '',
      nameTamil: data['nameTamil'] ?? '',
      partyLogo: data['partyLogo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}