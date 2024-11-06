import 'package:flutter/material.dart';
import 'package:valais_roll/src/user/widgets/nav_bar.dart';
import 'package:valais_roll/src/user/widgets/top_bar.dart';

/// A base page widget that provides a consistent layout with a top bar and an optional bottom navigation bar.
/// It also supports an optional back button with a confirmation dialog.
class BasePage extends StatelessWidget {
  final String title; // The title to display in the top bar
  final Widget body; // The main content of the page
  final bool isBottomNavBarEnabled; // Whether the bottom navigation bar is enabled
  final VoidCallback? onBackButtonPressed; // The callback to execute when the back button is pressed
  final bool showConfirmationDialog; // Whether to show a confirmation dialog when the back button is pressed
  final String confirmationDialogText; // The text to display in the confirmation dialog
  final bool enableBackButton; // Whether the back button is enabled

  /// Creates a [BasePage] widget.
  ///
  /// The [body] parameter is required.
  /// The [title] parameter defaults to 'ValaisRoll'.
  /// The [isBottomNavBarEnabled] parameter defaults to true.
  /// The [showConfirmationDialog] parameter defaults to false.
  /// The [confirmationDialogText] parameter defaults to a generic confirmation message.
  /// The [enableBackButton] parameter defaults to true.
  const BasePage({
    this.title = 'ValaisRoll',
    required this.body,
    this.isBottomNavBarEnabled = true,
    this.onBackButtonPressed,
    this.showConfirmationDialog = false,
    this.confirmationDialogText = 'Do you really want to leave this page? Any unsaved changes will be lost.',
    this.enableBackButton = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: title,
        onBackButtonPressed: onBackButtonPressed,
        showConfirmationDialog: showConfirmationDialog,
        confirmationDialogText: confirmationDialogText,
        enableBackButton: enableBackButton, 
      ),
      body: body,
      bottomNavigationBar: BottomNavBar(
        isEnabled: isBottomNavBarEnabled,
        currentRoute: ModalRoute.of(context)?.settings.name ?? '/', // Get the current route name
      ),
    );
  }
}