import 'package:flutter/material.dart';
import 'package:evoteapp/config/theme.dart';
import 'package:evoteapp/services/vote_service.dart';
import 'package:evoteapp/services/admin_dashboard_service.dart';
import 'package:evoteapp/models/candidate.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  ResultPageState createState() => ResultPageState();
}

class ResultPageState extends State<ResultPage> {
  final VoteService _voteService = VoteService();
  final AdminDashboardService _dashboardService = AdminDashboardService();
  final formatNumber = NumberFormat("#,###");
  final formatDecimal = NumberFormat("##0.00");

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.adminTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Election Results'),
          centerTitle: true,
          backgroundColor: const Color(0xFF1976D2),
        ),
        body: _buildResultSummary(),
      ),
    );
  }

  Widget _buildResultSummary() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _voteService.getLeadingCandidate(),
      builder: (context, leaderSnapshot) {
        return StreamBuilder<Map<String, int>>(
          stream: _dashboardService.getVoterStats(),
          builder: (context, voterSnapshot) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _voteService.getVoteResults(),
              builder: (context, resultsSnapshot) {
                if (!leaderSnapshot.hasData ||
                    !voterSnapshot.hasData ||
                    !resultsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final leaderInfo = leaderSnapshot.data!;
                final voterStats = voterSnapshot.data!;
                final results = resultsSnapshot.data!;
                final totalVotes = voterStats['votedVoters'] ?? 0;
                final totalRegistered = voterStats['totalVoters'] ?? 0;
                final votePercentage = totalRegistered > 0
                    ? (totalVotes / totalRegistered * 100)
                    : 0.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Election Progress Summary
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Election Progress',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: totalRegistered > 0
                                    ? totalVotes / totalRegistered
                                    : 0,
                                minHeight: 10,
                                backgroundColor: Colors.grey[200],
                                color: const Color(0xFF1976D2),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total votes cast: ${formatNumber.format(totalVotes)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                  Text(
                                    '${formatDecimal.format(votePercentage)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Out of ${formatNumber.format(totalRegistered)} registered voters',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Leading Candidate
                      if (leaderInfo['hasLeader'] == true) ...[
                        Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          color: leaderInfo['hasWon'] == true
                              ? Colors.green[50]
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Leading Candidate',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                    if (leaderInfo['hasWon'] == true) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Winner',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildCandidateLeaderCard(
                                  leaderInfo['candidate'] as Candidate,
                                  leaderInfo['votes'] as int,
                                  leaderInfo['percentage'] as double,
                                  isLeader: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // All Candidates Results
                      const Text(
                        'All Candidates',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          final candidate = result['candidate'] as Candidate;
                          final votes = result['votes'] as int;
                          final percentage = result['percentage'] as double;

                          return _buildCandidateResultCard(
                              candidate, votes, percentage);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCandidateResultCard(
      Candidate candidate, int votes, double percentage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Party logo or initials in circle
            _buildCandidateAvatar(candidate, 24),
            const SizedBox(width: 12),

            // Candidate info and progress bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.nameEnglish,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: LinearPercentIndicator(
                          percent: percentage / 100,
                          lineHeight: 18.0,
                          backgroundColor: Colors.grey[200],
                          progressColor: _getCandidateColor(candidate),
                          animation: true,
                          animationDuration: 500,
                          padding: EdgeInsets.zero,
                          barRadius: const Radius.circular(9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${formatDecimal.format(percentage)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Vote count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Votes',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  formatNumber.format(votes),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateLeaderCard(
      Candidate candidate, int votes, double percentage,
      {bool isLeader = false}) {
    return Card(
      elevation: isLeader ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLeader
            ? BorderSide(color: _getCandidateColor(candidate), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Party logo or candidate picture
            _buildCandidateAvatar(candidate, 40, showImageUrl: true),
            const SizedBox(width: 16),

            // Candidate details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.nameEnglish,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  CircularPercentIndicator(
                    radius: 30.0,
                    lineWidth: 8.0,
                    percent: percentage / 100,
                    center: Text("${percentage.toStringAsFixed(1)}%"),
                    progressColor: _getCandidateColor(candidate),
                    backgroundColor: Colors.grey[200]!,
                    animation: true,
                    animationDuration: 1000,
                  ),
                ],
              ),
            ),

            // Vote count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Votes',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  formatNumber.format(votes),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1976D2),
                  ),
                ),
                if (isLeader && percentage > 50) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '50%+ Majority',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateAvatar(Candidate candidate, double radius,
      {bool showImageUrl = false}) {
    final initialsText = _getCandidateInitials(candidate.nameEnglish);
    final candidateColor = _getCandidateColor(candidate);

    // Check if party logo exists
    if (candidate.partyLogo.isNotEmpty) {
      try {
        // Handle data URLs (base64 encoded images)
        return CircleAvatar(
          radius: radius,
          backgroundColor: candidateColor.withOpacity(0.2),
          child: CircleAvatar(
            radius: radius - 2,
            backgroundColor: Colors.white,
            backgroundImage: MemoryImage(
              Uri.parse(candidate.partyLogo).data!.contentAsBytes(),
            ),
            onBackgroundImageError: (_, __) {
              // If there's an error loading the image, this will trigger
              debugPrint(
                  'Error loading party logo: ${candidate.partyLogo.substring(0, min(50, candidate.partyLogo.length))}...');
            },
            child: Text(
              initialsText,
              style: TextStyle(
                color: candidateColor,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.6,
              ),
            ),
          ),
        );
      } catch (e) {
        debugPrint('Exception loading party logo: $e');
        // Fall through to the fallback avatar
      }
    }

    // Fallback to a nicely styled initials avatar
    return CircleAvatar(
      radius: radius,
      backgroundColor: candidateColor,
      child: Text(
        initialsText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(
      List<Map<String, dynamic>> results) {
    return results.map((result) {
      final candidate = result['candidate'] as Candidate;
      final percentage = result['percentage'] as double;
      final color = _getCandidateColor(candidate);

      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  String _getCandidateInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return name.length > 1 ? name.substring(0, 2).toUpperCase() : name;
  }

  Color _getCandidateColor(Candidate candidate) {
    // This would typically be based on party colors, but for simplicity
    // we'll generate a color based on the candidate's name
    final hash = candidate.nameEnglish.hashCode.abs();

    // Predefined colors for major parties in Sri Lanka
    if (candidate.nameEnglish.toLowerCase().contains('rajapaksa') ||
        candidate.partyLogo.toLowerCase().contains('pohottuwa')) {
      return const Color(0xFF800000); // Deep red/maroon for SLPP
    } else if (candidate.nameEnglish.toLowerCase().contains('premadasa') ||
        candidate.partyLogo.toLowerCase().contains('elephant')) {
      return Colors.green;
    } else if (candidate.nameEnglish.toLowerCase().contains('dissanayake') ||
        candidate.partyLogo.toLowerCase().contains('jvp')) {
      return Colors.red;
    }

    // Generate color for other candidates
    return Color.fromARGB(
      255,
      (hash % 255),
      ((hash ~/ 255) % 200) + 55, // Ensure brightness
      ((hash ~/ (255 * 255)) % 200) + 55,
    );
  }
}
