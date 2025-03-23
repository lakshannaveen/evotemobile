import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evoteapp/models/user.dart';

class VoterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'voters';

  // Get all voters
  Stream<List<User>> getVoters() {
    return _firestore.collection(_collection).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => User.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id
      )).toList()
    );
  }

  // Add a new voter
  Future<void> addVoter(User voter) async {
    try {
      await _firestore.collection(_collection).add({
        ...voter.toMap(),
        'voteStatus': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding voter: $e');
      rethrow;
    }
  }

  // Update an existing voter
  Future<void> updateVoter(String docId, User voter) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        ...voter.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating voter: $e');
      rethrow;
    }
  }

  // Delete a voter
  Future<void> deleteVoter(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).delete();
    } catch (e) {
      print('Error deleting voter: $e');
      rethrow;
    }
  }

  // Search voters with prefix pattern matching for NIC and name
  Future<List<User>> searchVoters(String query) async {
    try {
      if (query.isEmpty) {
        QuerySnapshot querySnapshot = await _firestore.collection(_collection).get();
        return querySnapshot.docs.map((doc) => User.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id
        )).toList();
      }

      // Convert query to lowercase for case-insensitive comparison
      final lowercaseQuery = query.toLowerCase();

      // Get documents that start with the query in either NIC or name
      QuerySnapshot nicResults = await _firestore
          .collection(_collection)
          .where('nic', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('nic', isLessThan: '$lowercaseQuery\uf8ff')
          .get();

      QuerySnapshot nameResults = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('name', isLessThan: '$lowercaseQuery\uf8ff')
          .get();

      // Combine and convert all results
      Set<String> seenIds = {};
      List<User> voters = [];

      for (var doc in [...nicResults.docs, ...nameResults.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          voters.add(User.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id
          ));
        }
      }

      return voters;
    } catch (e) {
      print('Error searching voters: $e');
      rethrow;
    }
  }
}
