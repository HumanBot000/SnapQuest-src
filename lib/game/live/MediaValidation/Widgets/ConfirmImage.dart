import 'dart:io' as io;
import 'package:appwrite/models.dart';
import 'package:appwrite_hackathon_2024/game/live/MediaValidation/Widgets/Buttons.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../animations/GradientText.dart';
import '../../../../classes/Challenge.dart';
import '../../Widgets/Timer.dart';

class ConfirmImage extends StatefulWidget {
  final XFile image;
  final Duration timeRemaining;
  final int roomID;
  final User user;
  final Challenge challenge;
  const ConfirmImage(
      {super.key,
      required this.image,
      required this.timeRemaining,
      required this.roomID,
      required this.user,
      required this.challenge});

  @override
  State<ConfirmImage> createState() => _ConfirmImageState();
}

class _ConfirmImageState extends State<ConfirmImage> {
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
                  "Do you want to publish this Image?",
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.onSecondary,
                    Theme.of(context).colorScheme.primary,
                  ]),
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
      body: Stack(
        children: [
          Column(
            children: [
              CountdownTimer(
                initialDuration: widget.timeRemaining,
                roomID: widget.roomID,
                user: widget.user,
              ),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.file(
                    io.File(widget.image.path),
                  ),
                  ConfirmationButtons(
                    file: widget.image,
                    user: widget.user,
                    roomID: widget.roomID,
                    timeRemaining: widget.timeRemaining,
                    challenge: widget.challenge,
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
