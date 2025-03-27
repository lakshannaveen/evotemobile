import 'package:flutter/material.dart';
import 'package:evoteapp/config/theme.dart';
import 'package:evoteapp/services/vote_service.dart';
import 'package:evoteapp/services/admin_dashboard_service.dart';
import 'package:evoteapp/models/candidate.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:evoteapp/services/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Results'),
        centerTitle: true,
      ),
      body: Container(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        child: _buildResultSummary(theme, isDarkMode),
      ),
    );
  }

  Widget _buildResultSummary(ThemeData theme, bool isDarkMode) {
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
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
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
                      _buildElectionProgressCard(
                        theme,
                        isDarkMode,
                        totalVotes,
                        totalRegistered,
                        votePercentage,
                      ),
                      if (leaderInfo['hasLeader'] == true)
                        _buildLeadingCandidateCard(
                          theme,
                          isDarkMode,
                          leaderInfo,
                        ),
                      _buildAllCandidatesSection(
                        theme,
                        isDarkMode,
                        results,
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

  Widget _buildElectionProgressCard(
      ThemeData theme,
      bool isDarkMode,
      int totalVotes,
      int totalRegistered,
      double votePercentage,
      ) {
    return Card(
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Election Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalRegistered > 0 ? totalVotes / totalRegistered : 0,
              minHeight: 10,
              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total votes cast: ${formatNumber.format(totalVotes)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${formatDecimal.format(votePercentage)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Text(
              'Out of ${formatNumber.format(totalRegistered)} registered voters',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingCandidateCard(
      ThemeData theme,
      bool isDarkMode,
      Map<String, dynamic> leaderInfo,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: isDarkMode
          ? leaderInfo['hasWon'] == true
          ? Colors.green[900]!.withOpacity(0.3)
          : Colors.grey[800]
          : leaderInfo['hasWon'] == true
          ? Colors.green[50]
          : Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Leading Candidate',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (leaderInfo['hasWon'] == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
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
              candidate: leaderInfo['candidate'] as Candidate,
              votes: leaderInfo['votes'] as int,
              percentage: leaderInfo['percentage'] as double,
              theme: theme,
              isDarkMode: isDarkMode,
              isLeader: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCandidatesSection(
      ThemeData theme,
      bool isDarkMode,
      List<Map<String, dynamic>> results,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Candidates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return _buildCandidateResultCard(
              candidate: result['candidate'] as Candidate,
              votes: result['votes'] as int,
              percentage: result['percentage'] as double,
              theme: theme,
              isDarkMode: isDarkMode,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCandidateResultCard({
    required Candidate candidate,
    required int votes,
    required double percentage,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            _buildCandidateAvatar(candidate, 24, theme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.nameEnglish,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: LinearPercentIndicator(
                          percent: percentage / 100,
                          lineHeight: 18.0,
                          backgroundColor:
                          isDarkMode ? Colors.grey[700] : Colors.grey[200],
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Votes',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  formatNumber.format(votes),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateLeaderCard({
    required Candidate candidate,
    required int votes,
    required double percentage,
    required ThemeData theme,
    required bool isDarkMode,
    bool isLeader = false,
  }) {
    return Card(
      elevation: isLeader ? 4 : 2,
      color: isDarkMode ? Colors.grey[800] : Colors.white,
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
            _buildCandidateAvatar(candidate, 40, theme, showImageUrl: true),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.nameEnglish,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CircularPercentIndicator(
                    radius: 30.0,
                    lineWidth: 8.0,
                    percent: percentage / 100,
                    center: Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                    progressColor: _getCandidateColor(candidate),
                    backgroundColor:
                    isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                    animation: true,
                    animationDuration: 1000,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Votes',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  formatNumber.format(votes),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: theme.colorScheme.primary,
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

  Widget _buildCandidateAvatar(Candidate candidate, double radius, ThemeData theme,
      {bool showImageUrl = false}) {
    final initialsText = _getCandidateInitials(candidate.nameEnglish);
    final candidateColor = _getCandidateColor(candidate);

    if (candidate.partyLogo.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: radius,
          backgroundColor: candidateColor.withOpacity(0.2),
          child: CircleAvatar(
            radius: radius - 2,
            backgroundColor: theme.cardColor,
            backgroundImage: MemoryImage(
              Uri.parse(candidate.partyLogo).data!.contentAsBytes(),
            ),
            onBackgroundImageError: (_, __) {
              debugPrint('Error loading party logo');
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
      }
    }

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

  String _getCandidateInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return name.length > 1 ? name.substring(0, 2).toUpperCase() : name;
  }

  Color _getCandidateColor(Candidate candidate) {
    final hash = candidate.nameEnglish.hashCode.abs();
    return Color.fromARGB(
      255,
      (hash % 255),
      ((hash ~/ 255) % 200) + 55,
      ((hash ~/ (255 * 255)) % 200) + 55,
    );
  }
}