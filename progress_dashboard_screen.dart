import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase.dart';
import 'app_localizations.dart';
import 'ui.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  bool _isLoading = true;
  int _totalSessions = 0;
  int _activeDays = 0;
  int _totalMinutes = 0;
  int _relaxationSessions = 0;
  int _exposureSessions = 0;
  int _mindfulnessSessions = 0;

  @override
  void initState() {
    super.initState();
    _loadProgressStats();
  }

  Future<void> _loadProgressStats() async {
    final user = FirebaseService.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final sessionsSnapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('userId', isEqualTo: user.uid)
        .get();

    final sessions = sessionsSnapshot.docs;
    final uniqueDays = sessions
        .map((doc) {
          final timestamp = doc.data()['date'] as Timestamp?;
          if (timestamp == null) return null;
          final date = timestamp.toDate();
          return DateTime(date.year, date.month, date.day);
        })
        .whereType<DateTime>()
        .toSet()
        .length;

    final totalSeconds = sessions.fold<int>(0, (sum, doc) {
      return sum + (doc.data()['duration'] as int? ?? 0);
    });

    int countType(String type) {
      return sessions.where((doc) => doc.data()['type'] == type).length;
    }

    setState(() {
      _totalSessions = sessions.length;
      _activeDays = uniqueDays;
      _totalMinutes = totalSeconds ~/ 60;
      _relaxationSessions = countType('relaxation');
      _exposureSessions = countType('exposure');
      _mindfulnessSessions = countType('mindfulness');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.translate('progress_dashboard') ?? 'Progress Dashboard',
        ),
        backgroundColor: AppUI.primaryWhite,
        foregroundColor: AppUI.textColor,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppUI.gradientHeaderCard(
                    title: l10n?.translate('weekly_progress') ?? 'Weekly Progress',
                    content: Column(
                      children: [
                        Text(
                          l10n?.translate('track_your_growth') ??
                              'Track your minutes, sessions and wellness progress.',
                          style: AppUI.bodyText,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: (_totalSessions / 12).clamp(0, 1),
                          color: AppUI.purplePrimary,
                          backgroundColor: AppUI.purplePrimary.withOpacity(0.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n?.translate('monthly_goal_status') ??
                              'You have completed $_totalSessions of 12 planned sessions.',
                          style: AppUI.captionText,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMetricsRow(context),
                  const SizedBox(height: 24),
                  AppUI.card(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildCategoryTile(
                          context,
                          title: l10n?.translate('relaxation_sessions') ??
                              'Relaxation Sessions',
                          count: _relaxationSessions,
                          color: AppUI.purplePrimary,
                        ),
                        const SizedBox(height: 12),
                        _buildCategoryTile(
                          context,
                          title: l10n?.translate('exposure_sessions') ??
                              'Exposure Sessions',
                          count: _exposureSessions,
                          color: AppUI.purpleSecondary,
                        ),
                        const SizedBox(height: 12),
                        _buildCategoryTile(
                          context,
                          title: l10n?.translate('mindfulness_sessions') ??
                              'Mindfulness Sessions',
                          count: _mindfulnessSessions,
                          color: AppUI.purpleAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricsRow(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _buildMetricCard(
          title: l10n?.translate('total_sessions') ?? 'Total Sessions',
          value: '$_totalSessions',
          color: AppUI.purplePrimary,
        ),
        const SizedBox(width: 12),
        _buildMetricCard(
          title: l10n?.translate('active_days') ?? 'Active Days',
          value: '$_activeDays',
          color: AppUI.purpleSecondary,
        ),
        const SizedBox(width: 12),
        _buildMetricCard(
          title: l10n?.translate('total_minutes') ?? 'Total Minutes',
          value: '$_totalMinutes',
          color: AppUI.purpleAccent,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppUI.captionText.copyWith(color: color)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppUI.bodyText.copyWith(fontWeight: FontWeight.w600)),
          Text(
            '$count',
            style: AppUI.headingSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
