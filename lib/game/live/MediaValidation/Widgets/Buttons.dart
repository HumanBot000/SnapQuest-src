import 'package:flutter/material.dart';

class ConfirmationButtons extends StatefulWidget {
  const ConfirmationButtons({super.key});

  @override
  State<ConfirmationButtons> createState() => _ConfirmationButtonsState();
}

class _ConfirmationButtonsState extends State<ConfirmationButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.delete),
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary)),
          ),
        ),
      ],
    );
  }
}
