import 'dart:io';
import 'package:appwrite_hackathon_2024/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../MediaValidation/Widgets/ConfirmImage.dart';
import '../MediaValidation/Widgets/ConfirmVideo.dart';

class CaptureMedia extends StatefulWidget {
  final CameraController controller;
  final Duration timeRemaining;
  final bool takePicture;
  const CaptureMedia(
      {super.key,
      required this.controller,
      required this.timeRemaining,
      required this.takePicture});

  @override
  State<CaptureMedia> createState() => _CaptureMediaState();
}

class _CaptureMediaState extends State<CaptureMedia> {
  late final Future<void> _initializeControllerFuture =
      widget.controller.initialize();
  bool _isRecordingVideo = false;

  void _recordVideo() async {
    if (_isRecordingVideo) {
      final file = await widget.controller.stopVideoRecording();
      setState(() => _isRecordingVideo = false);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmVideo(video: file),
          ));
    } else {
      await widget.controller.prepareForVideoRecording();
      await widget.controller.startVideoRecording();
      setState(() => _isRecordingVideo = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                              image: image,
                              timeRemaining: widget.timeRemaining,
                            )));
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
    );
  }
}
