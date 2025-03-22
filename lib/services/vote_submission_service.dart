import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vote.dart'; // Assuming you have a Vote model

class VoteSubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'votes'; // Collection to store votes

  Future<String?> submitVote(
      String nic, String userId, String candidateId) async {
    try {
      // Check if the user has already voted
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'You have already voted'; // Custom error message
      }

      // Save the vote
      final vote = Vote(nic: nic, voterId: userId, candidateId: candidateId);

      await _firestore.collection(_collection).add(vote.toJson());

      return 'Vote submitted successfully'; // Return success message
    } catch (e) {
      print('Error submitting vote: $e');
      return 'An error occurred. Please try again.'; // Custom error message
    }
  }
}
