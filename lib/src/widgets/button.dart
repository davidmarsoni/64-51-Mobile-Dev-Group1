import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFilled;
  final double? horizontalPadding;
  final double? verticalPadding;
  final Color? color; // Make color optional

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFilled = true,
    this.horizontalPadding,
    this.verticalPadding,
    this.color, // Make color optional
  });

  @override
  Widget build(BuildContext context) {
    const double defaultHorizontalPadding = 40.0;
    const double defaultVerticalPadding = 16.0;

    return isFilled
        ? FilledButton(
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding ?? defaultVerticalPadding,
                horizontal: horizontalPadding ?? defaultHorizontalPadding,
              ),
              textStyle: const TextStyle(fontSize: 18),
              backgroundColor: color, // Use the optional color
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
              side: color != null ? BorderSide(color: color!) : null, // Use the optional color
            ),
            onPressed: onPressed,
            child: Text(text),
          );
  }
}