import 'package:flutter/material.dart';
import 'package:valais_roll/src/user/widgets/nav_bar.dart';
import 'package:valais_roll/src/user/widgets/top_bar.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final bool isBottomNavBarEnabled;
  final VoidCallback? onBackButtonPressed;
  final bool showConfirmationDialog;
  final String confirmationDialogText;

  const BasePage({
    this.title = 'ValaisRoll',
    required this.body,
    this.isBottomNavBarEnabled = true,
    this.onBackButtonPressed,
    this.showConfirmationDialog = false,
    this.confirmationDialogText = 'Do you really want to leave this page? Any unsaved changes will be lost.',
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
      ),
      body: body,
      bottomNavigationBar: BottomNavBar(
        isEnabled: isBottomNavBarEnabled,
        currentRoute: ModalRoute.of(context)?.settings.name ?? '/',
      ),
    );
  }
}