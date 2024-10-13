import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../main.dart';

class ChallengeDrawerAnimation extends StatefulWidget {
  final List<String> challenges;
  final String finalWord;
  final Duration wordDuration;
  final Duration finalWordDuration;

  const ChallengeDrawerAnimation({
    super.key,
    required this.challenges,
    required this.finalWord,
    required this.wordDuration,
    required this.finalWordDuration,
  });

  @override
  _ChallengeDrawerAnimationState createState() =>
      _ChallengeDrawerAnimationState();
}

class _ChallengeDrawerAnimationState extends State<ChallengeDrawerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;
  bool? _isDrawing = null;
  int wordsShown = 0;
  final Random random = Random();
  final player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _startDrawing();
  }

  Future<void> _playSoundEffect() async {
    final player = AudioPlayer();
    await player.play(AssetSource('src/audio/effects/wheel_of_fortune.mp3'));
  }

  void _startDrawing() {
    _currentIndex = 0;
    _isDrawing = true;
    _controller.forward();
    _animateChallenges();
  }

  Future<void> _animateChallenges() async {
    while (_isDrawing!) {
      await Future.delayed(widget.wordDuration);
      _currentIndex = random.nextInt(widget.challenges.length);
      wordsShown++;
      _controller.forward(from: 0);
      if (wordsShown > 5) {
        await _showFinalWord();
        break;
      }
    }
  }

  Future<void> _showFinalWord() async {
    await Future.delayed(widget.finalWordDuration);
    _controller.stop();
    setState(() {
      _currentIndex = -1;
      _isDrawing = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: _animation.value,
            child: Transform.translate(
              offset: Offset(0, (_animation.value - 0.5) * 100),
              child: Text(
                _currentIndex > 0
                    ? widget.challenges[_currentIndex < widget.challenges.length
                        ? _currentIndex
                        : 0]
                    : widget.finalWord,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
