import 'package:appwrite/models.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../classes/Challenge.dart';
import '../../../../main.dart';
import '../../mediaApproval/Widgets/Stack.dart';
import '../../management/upload.dart';

class ConfirmationButtons extends StatefulWidget {
  final XFile file;
  final User user;
  final int roomID;
  final Duration timeRemaining;
  final Challenge challenge;
  const ConfirmationButtons(
      {super.key,
      required this.file,
      required this.user,
      required this.roomID,
      required this.timeRemaining,
      required this.challenge});

  @override
  State<ConfirmationButtons> createState() => _ConfirmationButtonsState();
}

class _ConfirmationButtonsState extends State<ConfirmationButtons> {
  bool _uploading = false;
  Future<void> _uploadMedia(
      XFile file, Duration timeRemaining, Challenge challenge) async {
    if (_uploading) {
      return;
    }
    _uploading = true;
    logger.i("Uploading File");
    try {
      String medium = await uploadFile(file.path, widget.user, widget.roomID);
      await insertFileToDB(medium, widget.user, widget.roomID);
    } catch (e) {
      logger.e(e);
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return CheckingStack(
        timeRemaining: timeRemaining,
        challenge: challenge,
        roomID: widget.roomID,
        user: widget.user,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.delete),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: IconButton(
            onPressed: () => _uploadMedia(
                widget.file, widget.timeRemaining, widget.challenge),
            icon: const Icon(Icons.check),
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
