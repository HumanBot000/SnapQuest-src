import 'dart:io' as io;
import 'package:appwrite/models.dart';
import 'package:appwrite_hackathon_2024/game/live/MediaValidation/Widgets/Buttons.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../animations/GradientText.dart';
import '../../Widgets/Timer.dart';

class ConfirmVideo extends StatefulWidget {
  final XFile video;
  final Duration timeRemaining;
  final int roomID;
  final User user;
  const ConfirmVideo(
      {super.key,
      required this.video,
      required this.timeRemaining,
      required this.roomID,
      required this.user});

  @override
  State<ConfirmVideo> createState() => _ConfirmVideoState();
}

class _ConfirmVideoState extends State<ConfirmVideo> {
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    _videoPlayerController =
        VideoPlayerController.file(io.File(widget.video.path));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
    setState(() {
      _isVideoInitialized = true;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Wrap(
              alignment: WrapAlignment.center,
              children: [
                GradientText(
                  "Do you want to publish this Video?",
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.onSecondary,
                      Theme.of(context).colorScheme.primary,
                    ],
                  ),
                  style: const TextStyle(
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _isVideoInitialized
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_videoPlayerController),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.1,
                  child: Container(
                    margin: EdgeInsets.all(32),
                    child: CountdownTimer(
                      initialDuration: widget.timeRemaining,
                    ),
                  ),
                ),
                ConfirmationButtons(
                  file: widget.video,
                  user: widget.user,
                  roomID: widget.roomID,
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
