import 'package:flutter/material.dart';

import '../../../classes/Challenge.dart';
import '../Widgets/Game.dart';

void navigateToGameScreen(BuildContext context, Challenge gameChallenge) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return RunningGame(activeChallenge: gameChallenge);
  }));
}
