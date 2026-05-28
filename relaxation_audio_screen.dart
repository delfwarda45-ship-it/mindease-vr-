import 'dart:async';
import 'package:flutter/material.dart';
import 'audio_service.dart';
import 'app_localizations.dart';
import 'ui.dart';

class RelaxationAudioScreen extends StatefulWidget {
  const RelaxationAudioScreen({super.key});

  @override
  State<RelaxationAudioScreen> createState() => _RelaxationAudioScreenState();
}

class _RelaxationAudioScreenState extends State<RelaxationAudioScreen> {
  late AudioService _audioService;
  bool _isReady = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _timer;

  final String _audioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  @override
  void initState() {
    super.initState();
    _audioService = AudioService.network(_audioUrl);
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    await _audioService.initialize();
    setState(() {
      _duration = _audioService.duration;
      _isReady = true;
    });
    _startPositionUpdates();
  }

  void _startPositionUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_audioService.isInitialized) {
        setState(() {
          _position = _audioService.position;
          _isPlaying = _audioService.isPlaying;
        });
      }
    });
  }

  void _togglePlayback() {
    if (!_isReady) return;
    if (_audioService.isPlaying) {
      _audioService.pause();
    } else {
      _audioService.play();
    }
    setState(() {
      _isPlaying = _audioService.isPlaying;
    });
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.translate('relaxation_audio') ?? 'Relaxation Audio',
        ),
        backgroundColor: AppUI.primaryWhite,
        foregroundColor: AppUI.textColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.translate('audio_wellness_session') ??
                  'Listen to a calming audio track designed for deep relaxation.',
              style: AppUI.bodyText.copyWith(height: 1.5),
            ),
            const SizedBox(height: 28),
            AppUI.card(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.headphones, size: 42, color: AppUI.purplePrimary),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.translate('ocean_breathing') ?? 'Ocean Breathing Mix',
                    style: AppUI.headingMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.translate('audio_track_description') ??
                        'A gentle ambient track with nature-inspired tones.',
                    style: AppUI.captionText,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (!_isReady)
                    AppUI.loadingIndicator(useGradient: true)
                  else ...[
                    Slider(
                      activeColor: AppUI.purplePrimary,
                      inactiveColor: AppUI.purpleSecondary.withOpacity(0.3),
                      value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                      min: 0,
                      max: _duration.inSeconds.toDouble() > 0
                          ? _duration.inSeconds.toDouble()
                          : 1,
                      onChanged: (value) {
                        final position = Duration(seconds: value.toInt());
                        _audioService.seekTo(position);
                        setState(() {
                          _position = position;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_format(_position)),
                          Text(_format(_duration)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppUI.gradientButton(
                      text: _isPlaying
                          ? (l10n?.translate('pause_audio') ?? 'Pause Audio')
                          : (l10n?.translate('play_audio') ?? 'Play Audio'),
                      onPressed: _togglePlayback,
                      icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.translate('audio_support_note') ??
                  'Use headphones for the best calming experience.',
              style: AppUI.captionText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
