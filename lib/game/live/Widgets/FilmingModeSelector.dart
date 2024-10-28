import 'package:SnapQuest/classes/Challenge.dart';
import 'package:flutter/material.dart';

class FilmingModeSelector extends StatefulWidget {
  final Challenge activeChallenge;
  final void Function(bool) setMediaType;
  final void Function(bool) toggleMic;
  const FilmingModeSelector(
      {super.key,
      required this.activeChallenge,
      required this.setMediaType,
      required this.toggleMic});

  @override
  State<FilmingModeSelector> createState() => _FilmingModeSelectorState();
}

class _FilmingModeSelectorState extends State<FilmingModeSelector> {
  late bool videoIsSelected;
  bool micIsEnabled = true;

  void _selectVideo() {
    setState(() {
      videoIsSelected = true;
      widget.setMediaType(false);
    });
  }

  void _selectPhoto() {
    setState(() {
      videoIsSelected = false;
      widget.setMediaType(true);
    });
  }

  void _switchMic() {
    setState(() {
      micIsEnabled = !micIsEnabled;
    });
    widget.toggleMic(micIsEnabled);
  }

  @override
  void initState() {
    super.initState();
    videoIsSelected = widget.activeChallenge.videosAllowed &&
        !widget.activeChallenge.photosAllowed;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        widget.activeChallenge.photosAllowed
            ? IconButton(
                onPressed: () => _selectPhoto(),
                icon: Icon(Icons.camera_alt,
                    color: videoIsSelected ? Colors.grey : Colors.green))
            : const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Colors.grey,
                    size: 30,
                  ),
                  Icon(
                    Icons.block,
                    color: Colors.red,
                    size: 40,
                  ),
                ],
              ),
        widget.activeChallenge.videosAllowed
            ? IconButton(
                onPressed: () => _selectVideo(),
                icon: Icon(
                  Icons.videocam,
                  color: videoIsSelected ? Colors.green : Colors.grey,
                ))
            : const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.videocam,
                    color: Colors.grey,
                    size: 30,
                  ),
                  Icon(
                    Icons.block,
                    color: Colors.red,
                    size: 40,
                  ),
                ],
              ),
        if (videoIsSelected)
          Padding(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.55),
            child: IconButton(
              onPressed: () => _switchMic(),
              icon: Icon(Icons.mic,
                  color: micIsEnabled
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary),
            ),
          ),
      ],
    );
  }
}
