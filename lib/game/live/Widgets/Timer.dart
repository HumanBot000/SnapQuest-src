import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../animations/GradientText.dart';

class CountdownTimer extends StatefulWidget {
  final Duration initialDuration;

  const CountdownTimer({super.key, required this.initialDuration});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _secondsRemaining;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadExpirationTime();
  }

  Future<void> _loadExpirationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final expirationTime = prefs.getInt('challenge_expiration_time');

    if (expirationTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final difference = expirationTime - now;

      if (difference > 0) {
        _secondsRemaining = difference ~/ 1000;
      } else {
        _secondsRemaining = 0;
      }
    } else {
      _setNewExpirationTime();
    }

    _startTimer();
  }

  Future<void> _setNewExpirationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final expirationTime =
        DateTime.now().add(widget.initialDuration).millisecondsSinceEpoch;
    await prefs.setInt('challenge_expiration_time', expirationTime);
    _secondsRemaining = widget.initialDuration.inSeconds;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    String seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return GradientText('$minutes:$seconds',
        style: const TextStyle(fontSize: 48),
        gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.secondary
        ]));
  }
}

Future<void> resetTimer() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('challenge_expiration_time');
}
