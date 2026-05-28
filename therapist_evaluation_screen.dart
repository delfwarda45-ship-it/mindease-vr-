import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'ui.dart';

class TherapistEvaluationScreen extends StatefulWidget {
  const TherapistEvaluationScreen({super.key});

  @override
  State<TherapistEvaluationScreen> createState() =>
      _TherapistEvaluationScreenState();
}

class _TherapistEvaluationScreenState
    extends State<TherapistEvaluationScreen> {
  int _moodLevel = 4;
  int _stressLevel = 3;
  final TextEditingController _notesController = TextEditingController();
  bool _submitted = false;

  void _submitEvaluation() {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitted = true;
    });
    AppUI.showSnackBar(
      context: context,
      message: AppLocalizations.of(context)
              ?.translate('evaluation_saved') ??
          'Evaluation saved successfully.',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.translate('therapist_evaluation') ??
              'Therapist Evaluation',
        ),
        backgroundColor: AppUI.primaryWhite,
        foregroundColor: AppUI.textColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n?.translate('evaluation_overview') ??
                    'Share your wellness insights and review a therapist-style progress summary.',
                style: AppUI.bodyText.copyWith(height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildStatusCard(
                title: l10n?.translate('mood_rating') ?? 'Mood Rating',
                value: '$_moodLevel / 5',
                description: l10n?.translate('mood_description') ??
                    'How balanced do you feel today?',
                icon: Icons.sentiment_satisfied,
                activeColor: AppUI.purplePrimary,
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                title: l10n?.translate('stress_level') ?? 'Stress Level',
                value: '$_stressLevel / 5',
                description: l10n?.translate('stress_description') ??
                    'Indicate your current stress intensity.',
                icon: Icons.self_improvement,
                activeColor: AppUI.purpleSecondary,
              ),
              const SizedBox(height: 20),
              Text(
                l10n?.translate('mood_scale_label') ??
                    'Drag the sliders to set your current state.',
                style: AppUI.captionText,
              ),
              const SizedBox(height: 12),
              _buildSlider(
                context,
                label: l10n?.translate('mood_rating') ?? 'Mood Rating',
                value: _moodLevel.toDouble(),
                onChanged: (value) => setState(() {
                  _moodLevel = value.toInt();
                }),
              ),
              const SizedBox(height: 12),
              _buildSlider(
                context,
                label: l10n?.translate('stress_level') ?? 'Stress Level',
                value: _stressLevel.toDouble(),
                onChanged: (value) => setState(() {
                  _stressLevel = value.toInt();
                }),
              ),
              const SizedBox(height: 20),
              AppUI.card(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.translate('session_notes') ?? 'Session Notes',
                      style: AppUI.headingSmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: l10n?.translate('notes_placeholder') ??
                            'Add any observations or feelings here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppUI.borderColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppUI.gradientButton(
                text: l10n?.translate('save_feedback') ?? 'Save Feedback',
                onPressed: _submitEvaluation,
              ),
              if (_submitted) ...[
                const SizedBox(height: 16),
                Text(
                  l10n?.translate('thank_you_evaluation') ??
                      'Your therapist-style evaluation has been recorded.',
                  style: AppUI.captionText,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color activeColor,
  }) {
    return AppUI.card(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [activeColor, AppUI.purpleSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: AppUI.primaryWhite, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppUI.headingSmall.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(value, style: AppUI.bodyText.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(description, style: AppUI.captionText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppUI.bodyText.copyWith(fontWeight: FontWeight.w600)),
        Slider(
          activeColor: AppUI.purplePrimary,
          inactiveColor: AppUI.purpleSecondary.withOpacity(0.3),
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          label: value.toInt().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
