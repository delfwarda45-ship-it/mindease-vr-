import 'dart:async';
import 'dart:ui'; // For blur effects
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase.dart';
import 'ui.dart';
import 'environment.dart' as env;

class VideoPlayerScreen extends StatefulWidget {
  final env.VREnvironment environment;

  const VideoPlayerScreen({
    Key? key,
    required this.environment,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _playbackTimer;
  int _elapsedSeconds = 0;
  bool _sessionSaved = false;
  bool _showControls = true; // To toggle HUD visibility
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset(widget.environment.videoAssetPath)
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {
          _totalDuration = _controller.value.duration;
        });
        _playVideo();
      });
  }

  @override
  void dispose() {
    _saveSession();
    _playbackTimer?.cancel();
    _hideControlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _playVideo() {
    _controller.play();
    _startPlaybackTimer();
    setState(() {
      _isPlaying = true;
    });
    _startHideControlsTimer();
  }

  void _pauseVideo() {
    _controller.pause();
    _playbackTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _showControls = true; // Show controls when paused
    });
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        _currentPosition = _controller.value.position;
      });
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls && _isPlaying) {
      _startHideControlsTimer();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _saveSession() async {
    if (_sessionSaved || _elapsedSeconds < 5) return;

    try {
      final userId = FirebaseService.getCurrentUser()?.uid;
      if (userId == null) return;

      final sessionId =
          'session_${DateTime.now().millisecondsSinceEpoch}_$userId';

      final sessionData = {
        'id': sessionId,
        'title': widget.environment.title,
        'description': 'VR Session: ${widget.environment.title}',
        'type': widget.environment.type,
        'category': widget.environment.category,
        'duration': _elapsedSeconds,
        'date': Timestamp.now(),
        'completed': true,
        'environmentId': widget.environment.id,
        'userId': userId,
        'videoAssetPath': widget.environment.videoAssetPath,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .set(sessionData);

      if (mounted) {
        setState(() {
          _sessionSaved = true;
        });
        AppUI.showSnackBar(
            context: context,
            message: 'Session saved successfully!',
            useGradient: true); //
      }
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : AppUI.loadingIndicator(useGradient: true),
            ),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showControls ? 0 : -100,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _buildGlassButton(
                          icon: Icons.arrow_back_ios_new,
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.environment.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(blurRadius: 4, color: Colors.black)
                                ],
                              ),
                            ),
                            Text(
                              widget.environment.type.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status Badge
                      if (_sessionSaved)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppUI.successColor.withOpacity(0.2), //
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppUI.successColor.withOpacity(0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check,
                                  color: AppUI.successColor, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "Saved",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showControls)
              Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _showControls ? 0 : -150,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Slider Row
                    Row(
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16),
                              activeTrackColor: AppUI.purplePrimary, //
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.white,
                              overlayColor:
                                  AppUI.purplePrimary.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: _controller.value.isInitialized
                                  ? _controller.value.position.inSeconds
                                      .toDouble()
                                      .clamp(0,
                                          _totalDuration.inSeconds.toDouble())
                                  : 0,
                              min: 0,
                              max: _totalDuration.inSeconds.toDouble() > 0
                                  ? _totalDuration.inSeconds.toDouble()
                                  : 1,
                              onChanged: (value) {
                                _controller
                                    .seekTo(Duration(seconds: value.toInt()));
                              },
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(_totalDuration),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Action Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Time elapsed indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined,
                                  color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '$_elapsedSeconds sec',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        // End Session Button
                        GestureDetector(
                          onTap: () {
                            _saveSession();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppUI.purplePrimary,
                                  AppUI.purpleSecondary
                                ], //
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppUI.purplePrimary.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              "End Session",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
