import 'dart:async';
import 'package:appwrite/models.dart';
import 'package:appwrite_hackathon_2024/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../classes/Challenge.dart';
import '../../../enums/gameConfig.dart';
import '../MediaValidation/Widgets/ConfirmImage.dart';
import '../MediaValidation/Widgets/ConfirmVideo.dart';

class CaptureMedia extends StatefulWidget {
  final CameraController controller;
  final Duration timeRemaining;
  final bool takePicture;
  final int roomID;
  final User user;
  final Challenge challenge;
  const CaptureMedia({
    super.key,
    required this.controller,
    required this.timeRemaining,
    required this.takePicture,
    required this.roomID,
    required this.user,
    required this.challenge,
  });

  @override
  State<CaptureMedia> createState() => _CaptureMediaState();
}

class _CaptureMediaState extends State<CaptureMedia>
    with SingleTickerProviderStateMixin {
  late final Future<void> _initializeControllerFuture =
      widget.controller.initialize();
  bool _isRecordingVideo = false;
  late AnimationController _animationController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: maxVideoDuration);
    _animationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _recordVideo() async {
    if (_isRecordingVideo) {
      final file = await widget.controller.stopVideoRecording();
      setState(() => _isRecordingVideo = false);
      _animationController.reset();
      _timer?.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmVideo(
            challenge: widget.challenge,
            video: file,
            roomID: widget.roomID,
            user: widget.user,
            timeRemaining: widget.timeRemaining,
          ),
        ),
      );
    } else {
      await widget.controller.prepareForVideoRecording();
      await widget.controller.startVideoRecording();
      setState(() => _isRecordingVideo = true);
      _animationController.forward();
      _timer = Timer(
        maxVideoDuration,
        () async {
          if (_isRecordingVideo) {
            final file = await widget.controller.stopVideoRecording();
            setState(() => _isRecordingVideo = false);
            _animationController.reset();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmVideo(
                  challenge: widget.challenge,
                  roomID: widget.roomID,
                  user: widget.user,
                  video: file,
                  timeRemaining: widget.timeRemaining,
                ),
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: _animationController.value,
                strokeWidth: 6,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
            // Record/Stop Button
            FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: Colors.grey.shade800,
              onPressed: () async {
                if (widget.takePicture) {
                  try {
                    await _initializeControllerFuture;
                    final image = await widget.controller.takePicture();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmImage(
                          challenge: widget.challenge,
                          user: widget.user,
                          roomID: widget.roomID,
                          image: image,
                          timeRemaining: widget.timeRemaining,
                        ),
                      ),
                    );
                  } catch (e) {
                    logger.e(e);
                  }
                } else {
                  _recordVideo();
                }
              },
              child: Icon(
                widget.takePicture
                    ? Icons.camera
                    : _isRecordingVideo
                        ? Icons.stop
                        : Icons.videocam,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
