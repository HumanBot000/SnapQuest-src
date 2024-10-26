import 'dart:async';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../animations/GradientText.dart';
import '../../../main.dart';
import '../../final/Widgets/Results.dart';

class CountdownTimer extends StatefulWidget {
  final Duration initialDuration;
  final User user;
  final int roomID;
  const CountdownTimer(
      {super.key,
      required this.initialDuration,
      required this.user,
      required this.roomID});

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
    if (_secondsRemaining == 0) {
      logger.i("time is up->moving to results");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //Don't know why I have to do this, but somehow flutter is always  giving ab back arrow in the appbar as leading, even though I didn't specified this
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    Results(user: widget.user, roomID: widget.roomID)),
            (Route route) => false);
      });
    }
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
