import 'package:appwrite/models.dart';
import 'package:SnapQuest/animations/GradientText.dart';
import 'package:SnapQuest/classes/Challenge.dart';
import 'package:SnapQuest/game/live/Widgets/FilmingModeSelector.dart';
import 'package:SnapQuest/game/live/Widgets/CaptureMedia.dart';
import 'package:SnapQuest/game/live/Widgets/Timer.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../enums/gameConfig.dart';
import '../../../main.dart';

class RunningGame extends StatefulWidget {
  final Challenge activeChallenge;
  final int roomID;
  final User user;
  const RunningGame({
    super.key,
    required this.activeChallenge,
    required this.roomID,
    required this.user,
  });

  @override
  State<RunningGame> createState() => _RunningGameState();
}

class _RunningGameState extends State<RunningGame> {
  late CameraController controller;
  late List<CameraDescription> cameras;
  late Duration _timeRemaining;
  bool isCameraInitialized = false;
  bool takePicture = true;
  bool micEnabled = true;

  Future<void> _loadCameras() async {
    cameras = await availableCameras();
    controller = CameraController(
        enableAudio: micEnabled,
        cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back),
        ResolutionPreset.medium);
    await controller.initialize();
    controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    controller.setFocusMode(FocusMode.auto);
    controller.setFlashMode(FlashMode.off);
    if (mounted) {
      setState(() {
        isCameraInitialized = true;
      });
    }
  }

  void _setMediaType(bool isPhoto) {
    setState(() {
      takePicture = isPhoto;
    });
  }

  void _toggleMic(bool isEnabled) {
    setState(() {
      micEnabled = isEnabled;
    });
    _loadCameras();
  }

  @override
  void initState() {
    logger.d("Difficulty ${widget.activeChallenge.difficulty}");
    _timeRemaining =
        challengeTimeLimitsByDifficulty[widget.activeChallenge.difficulty - 1];
    if (!widget.activeChallenge.photosAllowed) {
      _setMediaType(false);
    }
    super.initState();
    _loadCameras();
  }

  @override
  void dispose() {
    controller.dispose();
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
                  widget.activeChallenge.description,
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.onSecondary,
                    Theme.of(context).colorScheme.primary,
                  ]),
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CountdownTimer(
            initialDuration: _timeRemaining,
            user: widget.user,
            roomID: widget.roomID,
          ),
          Text(
              "Take a picture or video of this challenge. You have max. ${challengeTimeLimitsByDifficulty[widget.activeChallenge.difficulty - 1].inMinutes} minute${challengeTimeLimitsByDifficulty[widget.activeChallenge.difficulty - 1].inMinutes == 1 ? "" : "s"} time. Whoever finishes first, wins!",
              textAlign: TextAlign.center),
          if (isCameraInitialized)
            Container(
              padding: const EdgeInsets.fromLTRB(8, 32, 8, 16),
              child: Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  CameraPreview(controller),
                  FilmingModeSelector(
                    activeChallenge: widget.activeChallenge,
                    setMediaType: _setMediaType,
                    toggleMic: _toggleMic,
                  ),
                  CaptureMedia(
                    challenge: widget.activeChallenge,
                    user: widget.user,
                    roomID: widget.roomID,
                    controller: controller,
                    timeRemaining: _timeRemaining,
                    takePicture: takePicture,
                  )
                ],
              ),
            )
          else
            Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
