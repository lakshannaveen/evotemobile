import 'package:cloud_firestore/cloud_firestore.dart';

class CandidateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'candidates';

  // Get all candidates
  Stream<QuerySnapshot> getCandidates() {
    return _firestore.collection(_collection).snapshots();
  }

  // Add a new candidate
  Future<void> addCandidate(Map<String, dynamic> candidate) async {
    try {
      await _firestore.collection(_collection).add({
        ...candidate,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding candidate: $e');
      rethrow;
    }
  }

  // Update an existing candidate
  Future<void> updateCandidate(
      String id, Map<String, dynamic> candidate) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        ...candidate,
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
  Future<List<QueryDocumentSnapshot>> searchCandidates(String query) async {
    try {
      if (query.isEmpty) {
        QuerySnapshot querySnapshot =
            await _firestore.collection(_collection).get();
        return querySnapshot.docs;
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

      // Combine all results
      return [
        ...sinhalaResults.docs,
        ...englishResults.docs,
        ...tamilResults.docs
      ];
    } catch (e) {
      print('Error searching candidates: $e');
      rethrow;
    }
  }
}
