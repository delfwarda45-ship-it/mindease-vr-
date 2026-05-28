import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'breathing_circle.dart';
import 'ui.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    if (_isRunning) {
      _controller.stop();
    } else {
      _controller.repeat(reverse: true);
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  String _breathingPhase(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = _controller.value;
    if (value < 0.5) {
      return l10n?.translate('inhale') ?? 'Inhale';
    }
    return l10n?.translate('exhale') ?? 'Exhale';
  }

  String _breathingInstruction(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _isRunning
        ? l10n?.translate('follow_the_circle') ??
            'Follow the circle and breathe with it.'
        : l10n?.translate('tap_to_start') ?? 'Tap to start your breathing session.';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.translate('breathing_exercise') ?? 'Breathing Exercise',
        ),
        backgroundColor: AppUI.primaryWhite,
        foregroundColor: AppUI.textColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l10n?.translate('deep_breathing_session') ??
                  'A calming guided breathing session for focus and relaxation.',
              style: AppUI.bodyText.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            BreathingCircle(
              animation: CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOut,
              ),
              phase: _breathingPhase(context),
              instruction: _breathingInstruction(context),
            ),
            const SizedBox(height: 34),
            AppUI.gradientButton(
              text: _isRunning
                  ? (l10n?.translate('pause_session') ?? 'Pause Session')
                  : (l10n?.translate('start_session') ?? 'Start Session'),
              onPressed: _toggleBreathing,
              icon: _isRunning ? Icons.pause : Icons.play_arrow,
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.translate('breathing_rhythm') ??
                  'Inhale for 4 counts, exhale for 4 counts in a smooth rhythm.',
              style: AppUI.captionText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
