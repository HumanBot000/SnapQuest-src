import 'package:appwrite_hackathon_2024/animations/GradientText.dart';
import 'package:appwrite_hackathon_2024/classes/Challenge.dart';
import 'package:appwrite_hackathon_2024/game/live/Widgets/FilmingModeSelector.dart';
import 'package:appwrite_hackathon_2024/game/live/Widgets/TakePicture.dart';
import 'package:appwrite_hackathon_2024/game/live/Widgets/Timer.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class RunningGame extends StatefulWidget {
  final Challenge activeChallenge;

  const RunningGame({super.key, required this.activeChallenge});

  @override
  State<RunningGame> createState() => _RunningGameState();
}

class _RunningGameState extends State<RunningGame> {
  late CameraController controller;
  late List<CameraDescription> cameras;
  bool isCameraInitialized = false;
  final Duration _timeRemaining = const Duration(minutes: 1);

  Future<void> _loadCameras() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    if (mounted) {
      setState(() {
        isCameraInitialized = true;
      });
    }
  }

  @override
  void initState() {
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
          ),
          const Text(
              "Take a picture or video of this challenge. You have max. 1 minute time. Whoever finished first, wins!",
              textAlign: TextAlign.center),
          if (isCameraInitialized)
            Container(
              padding: const EdgeInsets.fromLTRB(8, 32, 8, 16),
              child: Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  CameraPreview(controller),
                  FilmingModeSelector(activeChallenge: widget.activeChallenge),
                  TakePicture(
                    controller: controller,
                    timeRemaining: _timeRemaining,
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