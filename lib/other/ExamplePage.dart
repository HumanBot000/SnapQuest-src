import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';

class Example extends StatefulWidget {
  final User user;
  const Example({super.key, required this.user});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(widget.user.name),
    );
  }
}
