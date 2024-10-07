import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaitingDots extends StatefulWidget {
  final List<double> _dyOffsets =
      List.generate(3, (_) => math.Random().nextDouble());

  WaitingDots({super.key});
  @override
  _WaitingDotsState createState() => _WaitingDotsState();
}

class _WaitingDotsState extends State<WaitingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: Duration(
            milliseconds: 500 + math.Random().nextInt(1000)), // Random duration
        vsync: this,
      )..repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                (-10 + widget._dyOffsets[index]) *
                    (_controllers[index].value - (index * 0.2 * math.pi)).abs(),
              ),
              child: const Text('.'),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
