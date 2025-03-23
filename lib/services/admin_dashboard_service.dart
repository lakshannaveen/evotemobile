import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get real-time voter statistics
  Stream<Map<String, int>> getVoterStats() {
    return _firestore.collection('voters').snapshots().map((snapshot) {
      final totalVoters = snapshot.docs.length;
      final votedVoters = snapshot.docs.where((doc) => doc.data()['voteStatus'] == true).length;
      return {
        'totalVoters': totalVoters,
        'votedVoters': votedVoters,
        'remainingVoters': totalVoters - votedVoters,
      };
    });
  }

  // Get candidate count
  Stream<int> getCandidateCount() {
    return _firestore.collection('candidates').snapshots().map((snapshot) => snapshot.docs.length);
  }

  // Get latest activities
  Stream<List<Map<String, dynamic>>> getRecentActivities() {
    return _firestore.collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
            'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
          };
        }).toList());
  }

  // Get election status
  Stream<Map<String, dynamic>> getElectionStatus() {
    return _firestore.collection('system').doc('election_status').snapshots().map((doc) {
      if (!doc.exists) {
        return {
          'isActive': false,
          'startTime': null,
          'endTime': null,
          'status': 'Not Started'
        };
      }
      final data = doc.data()!;
      return {
        'isActive': data['isActive'] ?? false,
        'startTime': (data['startTime'] as Timestamp?)?.toDate(),
        'endTime': (data['endTime'] as Timestamp?)?.toDate(),
        'status': data['status'] ?? 'Not Started',
        'lastUpdated': (data['lastUpdated'] as Timestamp?)?.toDate(),
      };
    });
  }

  // Update election status
  Future<void> updateElectionStatus(bool isActive, String status) async {
    await _firestore.collection('system').doc('election_status').set({
      'isActive': isActive,
      'status': status,
      'lastUpdated': FieldValue.serverTimestamp(),
      ...isActive
          ? {'startTime': FieldValue.serverTimestamp(), 'endTime': null}
          : {'endTime': FieldValue.serverTimestamp()},
    }, SetOptions(merge: true));
  }

  // Log activity
  Future<void> logActivity(String action, String description) async {
    await _firestore.collection('activities').add({
      'action': action,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get district-wise voter turnout
  Stream<Map<String, dynamic>> getDistrictTurnout() {
    return _firestore.collection('voters').snapshots().map((snapshot) {
      Map<String, Map<String, int>> districtStats = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final district = data['district'] as String;
        final hasVoted = data['voteStatus'] as bool;

        if (!districtStats.containsKey(district)) {
          districtStats[district] = {'total': 0, 'voted': 0};
        }

        districtStats[district]!['total'] = districtStats[district]!['total']! + 1;
        if (hasVoted) {
          districtStats[district]!['voted'] = districtStats[district]!['voted']! + 1;
        }
      }

      return {
        'districtStats': districtStats,
        'timestamp': DateTime.now().toIso8601String(),
      };
    });
  }
}