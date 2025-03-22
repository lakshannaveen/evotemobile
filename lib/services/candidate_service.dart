import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evoteapp/models/candidate.dart';

class CandidateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'candidates';

  // Get all candidates
  Stream<List<Candidate>> getCandidates() {
    return _firestore.collection(_collection).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Candidate.fromFirestore(doc)).toList()
    );
  }

  // Add a new candidate
  Future<void> addCandidate(Candidate candidate) async {
    try {
      await _firestore.collection(_collection).add({
        ...candidate.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding candidate: $e');
      rethrow;
    }
  }

  // Update an existing candidate
  Future<void> updateCandidate(String id, Candidate candidate) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        ...candidate.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating candidate: $e');
      rethrow;
    }
  }

  // Delete a candidate
  Future<void> deleteCandidate(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error deleting candidate: $e');
      rethrow;
    }
  }

  // Search candidates by name (in any language)
  Future<List<Candidate>> searchCandidates(String query) async {
    try {
      if (query.isEmpty) {
        QuerySnapshot querySnapshot = await _firestore.collection(_collection).get();
        return querySnapshot.docs.map((doc) => Candidate.fromFirestore(doc)).toList();
      }

      final lowercaseQuery = query.toLowerCase();

      // Search in all name fields
      QuerySnapshot sinhalaResults = await _firestore
          .collection(_collection)
          .where('nameSinhala', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('nameSinhala', isLessThan: '$lowercaseQuery\uf8ff')
          .get();

      QuerySnapshot englishResults = await _firestore
          .collection(_collection)
          .where('nameEnglish', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('nameEnglish', isLessThan: '$lowercaseQuery\uf8ff')
          .get();

      QuerySnapshot tamilResults = await _firestore
          .collection(_collection)
          .where('nameTamil', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('nameTamil', isLessThan: '$lowercaseQuery\uf8ff')
          .get();

      // Combine and convert all results
      Set<String> seenIds = {};
      List<Candidate> candidates = [];

      for (var doc in [...sinhalaResults.docs, ...englishResults.docs, ...tamilResults.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          candidates.add(Candidate.fromFirestore(doc));
        }
      }

      return candidates;
    } catch (e) {
      print('Error searching candidates: $e');
      rethrow;
    }
  }
}
