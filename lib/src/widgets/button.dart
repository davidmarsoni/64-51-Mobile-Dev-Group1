import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFilled;
  final double? horizontalPadding;
  final double? verticalPadding;
  final Color? color; 
  final IconData? icon; 

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFilled = true,
    this.horizontalPadding,
    this.verticalPadding,
    this.color, 
    this.icon, 
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
              backgroundColor: color, 
            ),
            onPressed: onPressed,
            child: icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon),
                      const SizedBox(width: 8),
                      Text(text),
                    ],
                  )
                : Text(text),
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding ?? defaultVerticalPadding,
                horizontal: horizontalPadding ?? defaultHorizontalPadding,
              ),
              textStyle: const TextStyle(fontSize: 18),
              side: color != null ? BorderSide(color: color!) : null, 
            ),
            onPressed: onPressed,
            child: icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon),
                      const SizedBox(width: 8),
                      Text(text),
                    ],
                  )
                : Text(text),
          );
  }
}