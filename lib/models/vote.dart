class Vote {
  final String nic;
  final String voterId;
  final String candidateId;

  Vote({required this.nic, required this.voterId, required this.candidateId});

  Map<String, dynamic> toJson() {
    return {
      'nic': nic,
      'voterId': voterId,
      'candidateId': candidateId,
    };
  }
}
