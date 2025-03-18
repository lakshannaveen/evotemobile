class ContactUsModel {
  final String nic;
  final String message;

  ContactUsModel({required this.nic, required this.message});

  Map<String, dynamic> toMap() {
    return {
      'nic': nic,
      'message': message,
    };
  }

  factory ContactUsModel.fromMap(Map<String, dynamic> map) {
    return ContactUsModel(
      nic: map['nic'] ?? '',
      message: map['message'] ?? '',
    );
  }
}
