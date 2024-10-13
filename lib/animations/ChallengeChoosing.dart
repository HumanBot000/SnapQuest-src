import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../classes/Challenge.dart';
import 'package:appwrite_hackathon_2024/animations/GradientText.dart';

class ChallengeDrawerAnimation extends StatefulWidget {
  final List<Challenge> challenges;
  final Challenge finalChallenge;
  final Duration wordDuration;
  final Duration finalWordDuration;
  final Function onFinished;

  const ChallengeDrawerAnimation({
    super.key,
    required this.challenges,
    required this.finalChallenge,
    required this.wordDuration,
    required this.finalWordDuration,
    required this.onFinished,
  });

  @override
  _ChallengeDrawerAnimationState createState() =>
      _ChallengeDrawerAnimationState();
}

class _ChallengeDrawerAnimationState extends State<ChallengeDrawerAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;
  bool? _isDrawing = null;
  int wordsShown = 0;
  final Random random = Random();
  final player = AudioPlayer();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _startDrawing();
  }

  Future<void> _playSoundEffect() async {
    final player = AudioPlayer();
    await player.play(AssetSource('audio/effects/wheel_of_fortune.mp3'));
  }

  void _startDrawing() {
    _currentIndex = 0;
    _isDrawing = true;
    _controller.forward();
    _animateChallenges();
  }

  Future<void> _animateChallenges() async {
    while (_isDrawing!) {
      _playSoundEffect();
      await Future.delayed(widget.wordDuration);
      _currentIndex = random.nextInt(widget.challenges.length);
      wordsShown++;
      _controller.forward(from: 0);
      if (wordsShown > 10) {
        break;
      }
    }
    await _showFinalWord();
  }

  Future<void> _showFinalWord() async {
    _playSoundEffect();
    setState(() {
      _currentIndex = -1;
    });
    await Future.delayed(widget.finalWordDuration);
    await _fadeController.forward();
    widget.onFinished(context, widget.finalChallenge);
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity:
                _currentIndex == -1 ? _fadeAnimation.value : _animation.value,
            child: Transform.translate(
              offset: Offset(0, (_animation.value - 0.5) * 100),
              child: GradientText(
                  _currentIndex >= 0
                      ? widget
                          .challenges[_currentIndex < widget.challenges.length
                              ? _currentIndex
                              : 0]
                          .description
                          .toString()
                      : widget.finalChallenge.description.toString(),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary
                  ])),
            ),
          ),
        ],
      ),
    );
  }
}
