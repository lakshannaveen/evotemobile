import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evoteapp/models/candidate.dart';

class VoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get real-time vote counts for each candidate
  Stream<List<Map<String, dynamic>>> getVoteResults() {
    return _firestore.collection('votes').snapshots().map((snapshot) async {
      // Get all candidates
      final candidatesSnapshot = await _firestore.collection('candidates').get();
      final candidates = candidatesSnapshot.docs.map((doc) => Candidate.fromFirestore(doc)).toList();
      
      // Count votes for each candidate
      Map<String, int> voteCounts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final candidateId = data['candidateId'] as String;
        voteCounts[candidateId] = (voteCounts[candidateId] ?? 0) + 1;
      }
      
      // Total number of votes cast
      final totalVotes = snapshot.docs.length;
      
      // Create result list with candidate details and vote counts
      List<Map<String, dynamic>> results = candidates.map((candidate) {
        final votes = voteCounts[candidate.id] ?? 0;
        final percentage = totalVotes > 0 ? (votes / totalVotes * 100) : 0;
        
        return {
          'candidate': candidate,
          'votes': votes,
          'percentage': percentage,
        };
      }).toList();
      
      // Sort by vote count in descending order
      results.sort((a, b) => b['votes'].compareTo(a['votes']));
      
      return results;
    }).asyncMap((value) async => value);
  }

  // Get vote counts by district
  Stream<Map<String, dynamic>> getDistrictResults() {
    return _firestore.collection('votes').snapshots().map((voteSnapshot) async {
      // Get all districts from voters collection
      final votersSnapshot = await _firestore.collection('voters').get();
      final districtVoterMap = <String, Map<String, String>>{};
      
      // Create a map of voterId to district
      for (var doc in votersSnapshot.docs) {
        final data = doc.data();
        final voterId = data['voterId'] as String;
        final district = data['district'] as String;
        districtVoterMap[voterId] = {'district': district, 'nic': data['nic'] as String};
      }
      
      // Get candidates
      final candidatesSnapshot = await _firestore.collection('candidates').get();
      final candidates = candidatesSnapshot.docs.map((doc) => Candidate.fromFirestore(doc)).toList();
      final candidateMap = {for (var c in candidates) c.id!: c};
      
      // Initialize district results
      Map<String, Map<String, dynamic>> districtResults = {};
      
      // Count votes by district and candidate
      for (var doc in voteSnapshot.docs) {
        final data = doc.data();
        final voterId = data['voterId'] as String;
        final candidateId = data['candidateId'] as String;
        
        if (districtVoterMap.containsKey(voterId)) {
          final district = districtVoterMap[voterId]!['district']!;
          
          if (!districtResults.containsKey(district)) {
            districtResults[district] = {
              'totalVotes': 0,
              'candidates': <String, int>{},
            };
          }
          
          districtResults[district]!['totalVotes'] = districtResults[district]!['totalVotes']! + 1;
          
          if (!districtResults[district]!['candidates'].containsKey(candidateId)) {
            districtResults[district]!['candidates'][candidateId] = 0;
          }
          
          districtResults[district]!['candidates'][candidateId] = 
              districtResults[district]!['candidates'][candidateId]! + 1;
        }
      }
      
      // Format results to include candidate details and percentages
      for (var district in districtResults.keys) {
        final totalDistrictVotes = districtResults[district]!['totalVotes'] as int;
        final candidateVotes = districtResults[district]!['candidates'] as Map<String, int>;
        
        // Convert to list of candidates with vote details
        final candidateResults = candidateVotes.entries.map((entry) {
          final candidateId = entry.key;
          final votes = entry.value;
          final percentage = totalDistrictVotes > 0 ? (votes / totalDistrictVotes * 100) : 0;
          
          return {
            'candidate': candidateMap[candidateId],
            'votes': votes,
            'percentage': percentage,
          };
        }).toList();
        
        // Sort by votes
        candidateResults.sort((a, b) => (b['votes'] as int).compareTo(a['votes'] as int));
        
        // Replace the original map with the formatted list
        districtResults[district]!['candidateResults'] = candidateResults;
      }
      
      return {
        'districtResults': districtResults,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }).asyncMap((value) async => value);
  }

  // Get leading candidate info
  Stream<Map<String, dynamic>> getLeadingCandidate() {
    return getVoteResults().map((results) {
      if (results.isEmpty) {
        return {
          'hasLeader': false,
          'candidate': null,
          'votes': 0,
          'percentage': 0.0,
        };
      }
      
      final leader = results[0];
      final totalVotes = results.fold(0, (sum, item) => sum + (item['votes'] as int));
      
      return {
        'hasLeader': true,
        'candidate': leader['candidate'],
        'votes': leader['votes'],
        'percentage': leader['percentage'],
        'totalVotes': totalVotes,
        'hasWon': leader['percentage'] > 50,  // Winning threshold in Sri Lanka is 50%+
      };
    });
  }
}