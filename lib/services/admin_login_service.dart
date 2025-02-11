import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:bcrypt/bcrypt.dart';

class AdminLoginService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Validates admin login and returns a JWT token if successful; null otherwise.
  Future<String?> adminLogin(String username, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection(
              'admin') // ensure your Firestore collection is named as such
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final adminData = querySnapshot.docs.first.data();

      // Verify password using bcrypt.
      if (BCrypt.checkpw(password, adminData['password'])) {
        // Generate JWT token.
        final jwt = JWT({
          'adminId': querySnapshot.docs.first.id,
          'role': 'admin',
        });
        final token = jwt.sign(SecretKey('evote_secret_key'));
        return token;
      }
      return null;
    } catch (e) {
      print('Error during admin login: $e');
      return null;
    }
  }
}
