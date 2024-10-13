import 'package:appwrite_hackathon_2024/animations/GradientText.dart';
import 'package:appwrite_hackathon_2024/classes/Challenge.dart';
import 'package:appwrite_hackathon_2024/game/live/Widgets/Timer.dart';
import 'package:flutter/material.dart';

class RunningGame extends StatefulWidget {
  final Challenge activeChallenge;
  RunningGame({required this.activeChallenge});

  @override
  State<RunningGame> createState() => _RunningGameState();
}

class _RunningGameState extends State<RunningGame> {
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
                Theme.of(context).colorScheme.secondary
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
                )
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: CountdownTimer(initialMinutes: 1)),
        ],
      ),
    );
  }
}
