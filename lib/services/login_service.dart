import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart'; // Import the User model

class LoginService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'voters'; // Firestore collection name

  Future<User?> validateLogin(String nic, String userId) async {
    try {
      final normalizedNic = nic.toUpperCase();

      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('voterId', isEqualTo: userId)
          .where('voteStatus', isEqualTo: false) // Ensure user hasn't voted
          .where('nic', isEqualTo: normalizedNic)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        return User.fromMap(documentData);
      } else {
        return null;
      }
    } catch (e) {
      print('Error validating login: $e');
      rethrow;
    }
  }
}
