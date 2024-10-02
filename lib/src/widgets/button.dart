import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFilled;
  final double? horizontalPadding;
  final double? verticalPadding;

  const Button({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isFilled = true,
    this.horizontalPadding,
    this.verticalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double defaultHorizontalPadding = 40.0;
    final double defaultVerticalPadding = 16.0;

    return isFilled
        ? FilledButton(
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding ?? defaultVerticalPadding,
                horizontal: horizontalPadding ?? defaultHorizontalPadding,
              ),
              textStyle: const TextStyle(fontSize: 18),
            ),
            onPressed: onPressed,
            child: Text(text),
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding ?? defaultVerticalPadding,
                horizontal: horizontalPadding ?? defaultHorizontalPadding,
              ),
              textStyle: const TextStyle(fontSize: 18),
            ),
            onPressed: onPressed,
            child: Text(text),
          );
  }
}