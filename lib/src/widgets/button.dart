import 'package:flutter/material.dart';

/// A customizable button widget that supports both filled and outlined styles.
/// It can also display an optional icon or image.
class Button extends StatelessWidget {
  final String text; // The text to display on the button
  final VoidCallback onPressed; // The callback to execute when the button is pressed
  final bool isFilled; // Whether the button is filled or outlined
  final double? horizontalPadding; // Optional horizontal padding
  final double? verticalPadding; // Optional vertical padding
  final Color? color; // Optional background color for the button
  final IconData? icon; // Optional icon to display on the button
  final Image? image; // Optional image to display on the button

  /// Creates a [Button] widget.
  ///
  /// The [text] and [onPressed] parameters are required.
  /// The [isFilled] parameter defaults to true.
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
    const double defaultHorizontalPadding = 40.0; // Default horizontal padding
    const double defaultVerticalPadding = 16.0; // Default vertical padding

    // Determine the button style based on the isFilled property
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
                if (image != null) image!, // Display the image if provided
                if (icon != null) Icon(icon), // Display the icon if provided
                if (image != null || icon != null) const SizedBox(width: 8), // Spacing between icon/image and text
                Text(text), // Display the button text
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
              side: color != null ? BorderSide(color: color!) : null, // Border color if provided
            ),
            onPressed: onPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image != null) image!, // Display the image if provided
                if (icon != null) Icon(icon), // Display the icon if provided
                if (image != null || icon != null) const SizedBox(width: 8), // Spacing between icon/image and text
                Text(text), // Display the button text
              ],
            ),
          );
  }
}