import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../models/user.dart';

class LoginService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'voters';
  final String _jwtSecret = "1020"; // can change this to any secret key

  Future<String?> validateLogin(String nic, String userId) async {
    try {
      final normalizedNic = nic.toUpperCase();

      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('voterId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        final user = User.fromMap(documentData);

        // Check if the user has already voted
        if (user.voteStatus == true) {
          return 'You have already voted'; // Custom error message
        }

        // Check if NIC matches
        if (user.nic != normalizedNic) {
          return 'Incorrect NIC'; // Custom error message
        }

        // Generate JWT token with user details
        final jwt = JWT({
          'voterId': user.userId,
          'name': user.fullName,
          'nic': user.nic,
          'voteStatus': user.voteStatus,
          'district': user.district,
          'pollingDivision': user.pollingDivision,
        });

        final token =
            jwt.sign(SecretKey(_jwtSecret), expiresIn: Duration(hours: 1));
        return token; // Return the generated token
      } else {
        return 'Incorrect User ID'; // Custom error message
      }
    } catch (e) {
      print('Error validating login: $e');
      return 'An error occurred. Please try again.';
    }
  }
}
