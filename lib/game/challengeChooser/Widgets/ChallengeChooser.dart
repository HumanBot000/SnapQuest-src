import 'package:flutter/material.dart';

import '../../../animations/ChallengeChoosing.dart';

class ChallengeChooser extends StatefulWidget {
  const ChallengeChooser({super.key});

  @override
  State<ChallengeChooser> createState() => _ChallengeChooserState();
}

class _ChallengeChooserState extends State<ChallengeChooser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChallengeDrawerAnimation(
        challenges: [
          'Do 10 push-ups',
          'Take a funny selfie',
          'Make a paper airplane',
          'Balance a book on your head',
          'Dance for 30 seconds',
        ],
        finalWord: "Take a funny selfie",
        wordDuration: Duration(milliseconds: 500),
        finalWordDuration: Duration(seconds: 5),
      ),
    );
  }
}
