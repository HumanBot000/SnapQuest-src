import 'package:appwrite_hackathon_2024/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../MediaValidation/Widgets/ConfirmMedia.dart';

class TakePicture extends StatefulWidget {
  final CameraController controller;
  final Duration timeRemaining;
  const TakePicture(
      {super.key, required this.controller, required this.timeRemaining});

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  late final Future<void> _initializeControllerFuture =
      widget.controller.initialize();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: Colors.grey.shade800,
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final image = await widget.controller.takePicture();
                logger.i("Media captured, now asking for confirmation...");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConfirmMedia(
                              image: image,
                              timeRemaining: widget.timeRemaining,
                            )));
              } catch (e) {
                logger.e(e);
              }
            },
            child: const Icon(
              Icons.camera,
            ),
          ),
        ),
      ],
    );
  }
}
