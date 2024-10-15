import 'package:appwrite_hackathon_2024/game/live/Widgets/Timer.dart';
import 'package:flutter/material.dart';

import '../../../classes/Challenge.dart';
import '../Widgets/Game.dart';

void navigateToGameScreen(BuildContext context, Challenge gameChallenge) {
  resetTimer();
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return RunningGame(activeChallenge: gameChallenge);
  }));
}