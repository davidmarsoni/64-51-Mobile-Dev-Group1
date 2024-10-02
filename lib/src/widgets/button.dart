import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFilled;

  const Button({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isFilled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isFilled
        ? FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
              textStyle: const TextStyle(fontSize: 18),
            ),
            onPressed: onPressed,
            child: Text(text),
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
              textStyle: const TextStyle(fontSize: 18),
            ),
            onPressed: onPressed,
            child: Text(text),
          );
  }
}