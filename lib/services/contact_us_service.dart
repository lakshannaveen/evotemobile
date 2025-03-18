import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact_us_model.dart';

class ContactUsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitContactUsData(ContactUsModel contactUsData) async {
    try {
      await _firestore.collection('contact_us').add(contactUsData.toMap());
    } catch (e) {
      throw Exception('Error submitting data: $e');
    }
  }
}
