import 'package:video_player/video_player.dart';

class AudioService {
  final VideoPlayerController controller;

  AudioService.network(String url)
      : controller = VideoPlayerController.network(url);

  Future<void> initialize() async {
    await controller.initialize();
    controller.setLooping(true);
  }

  Future<void> play() => controller.play();

  Future<void> pause() => controller.pause();

  Future<void> seekTo(Duration position) => controller.seekTo(position);

  bool get isInitialized => controller.value.isInitialized;

  bool get isPlaying => controller.value.isPlaying;

  Duration get position => controller.value.position;

  Duration get duration => controller.value.duration;

  void dispose() => controller.dispose();
}
