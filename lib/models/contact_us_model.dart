class ContactUsModel {
  final String nic;
  final String message;
  final String phoneNumber;

  ContactUsModel(
      {required this.nic, required this.message, required this.phoneNumber});

  Map<String, dynamic> toMap() {
    return {
      'nic': nic,
      'message': message,
      'phoneNumber': phoneNumber,
    };
  }

  factory ContactUsModel.fromMap(Map<String, dynamic> map) {
    return ContactUsModel(
      nic: map['nic'] ?? '',
      message: map['message'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}
