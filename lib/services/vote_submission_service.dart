import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vote.dart'; // Assuming you have a Vote model

class VoteSubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'votes'; // Collection to store votes

  Future<String?> submitVote(
      String nic, String userId, String candidateId) async {
    try {
      // Check if a vote already exists with the same voterId and nic
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('voterId', isEqualTo: userId)
          .where('nic', isEqualTo: nic)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'You have already voted'; // Return error if vote exists
      }

      // Save the vote
      final vote = Vote(nic: nic, voterId: userId, candidateId: candidateId);
      await _firestore.collection(_collection).add(vote.toJson());

      // Update the user's voteStatus to true after successful vote submission
      QuerySnapshot userSnapshot = await _firestore
          .collection('voters')
          .where('voterId', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        await _firestore
            .collection('voters')
            .doc(userSnapshot.docs.first.id)
            .update({'voteStatus': true});
      }

      return 'Vote submitted successfully'; // Return success message
    } catch (e) {
      print('Error submitting vote: $e');
      return 'An error occurred. Please try again.'; // Handle errors gracefully
    }
  }
}
