import 'dart:io';
import 'package:appwrite_hackathon_2024/game/live/MediaValidation/Widgets/Buttons.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ConfirmVideo extends StatefulWidget {
  final XFile video;
  const ConfirmVideo({super.key, required this.video});

  @override
  State<ConfirmVideo> createState() => _ConfirmVideoState();
}

class _ConfirmVideoState extends State<ConfirmVideo> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController =
        VideoPlayerController.file(File(widget.video.path));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Do you want to publish this Video?'),
        elevation: 0,
        backgroundColor: Colors.black26,
        actions: [],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_videoPlayerController),
                const ConfirmationButtons(),
              ],
            );
          }
        },
      ),
    );
  }
}
