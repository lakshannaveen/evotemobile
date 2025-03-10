import 'package:cloud_firestore/cloud_firestore.dart';

class VoterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'voters';

  // Get all voters
  Stream<QuerySnapshot> getVoters() {
    return _firestore.collection(_collection).snapshots();
  }

  // Add a new voter
  Future<void> addVoter(Map<String, dynamic> voter) async {
    try {
      await _firestore.collection(_collection).add({
        ...voter,
        'voteStatus': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding voter: $e');
      rethrow;
    }
  }

  // Update an existing voter
  Future<void> updateVoter(String id, Map<String, dynamic> voter) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        ...voter,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating voter: $e');
      rethrow;
    }
  }

  // Delete a voter
  Future<void> deleteVoter(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error deleting voter: $e');
      rethrow;
    }
  }

  // Search voters with prefix pattern matching for NIC and name
  Future<List<QueryDocumentSnapshot>> searchVoters(String query) async {
    try {
      if (query.isEmpty) {
        QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .get();
        return querySnapshot.docs;
      }

      // Convert query to lowercase for case-insensitive comparison
      final lowercaseQuery = query.toLowerCase();

      // Get documents that start with the query in either NIC or name
      QuerySnapshot nicResults = await _firestore
          .collection(_collection)
          .where('nic', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('nic', isLessThan: lowercaseQuery + '\uf8ff')
          .get();

      QuerySnapshot nameResults = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('name', isLessThan: lowercaseQuery + '\uf8ff')
          .get();

      // Combine the results
      return [...nicResults.docs, ...nameResults.docs];
    } catch (e) {
      print('Error searching voters: $e');
      rethrow;
    }
  }
}