import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFilled;
  final double? horizontalPadding;
  final double? verticalPadding;
  final Color? color;
  final IconData? icon; // Icon option
  final Image? image; // Image option

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFilled = true,
    this.horizontalPadding,
    this.verticalPadding,
    this.color,
    this.icon,
    this.image,
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
            // Display either an image or icon, depending on which is provided
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image != null) image!,
                if (icon != null) Icon(icon),
                if (image != null || icon != null) const SizedBox(width: 8), // Spacing between icon/image and text
                Text(text),
              ],
            ),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image != null) image!,
                if (icon != null) Icon(icon),
                if (image != null || icon != null) const SizedBox(width: 8), // Spacing between icon/image and text
                Text(text),
              ],
            ),
          );
  }
}
