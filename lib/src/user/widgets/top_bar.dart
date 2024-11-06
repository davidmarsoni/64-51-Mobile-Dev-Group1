import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A top bar widget that provides a consistent layout with a title, back button, and action buttons.
/// It also supports an optional back button with a confirmation dialog.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // The title to display in the top bar
  final VoidCallback? onBackButtonPressed; // The callback to execute when the back button is pressed
  final bool showConfirmationDialog; // Whether to show a confirmation dialog when the back button is pressed
  final String confirmationDialogText; // The text to display in the confirmation dialog
  final bool enableBackButton; // Whether the back button is enabled

  /// Creates a [TopBar] widget.
  ///
  /// The [title] parameter defaults to 'ValaisRoll'.
  /// The [showConfirmationDialog] parameter defaults to false.
  /// The [confirmationDialogText] parameter defaults to a generic confirmation message.
  /// The [enableBackButton] parameter defaults to true.
  const TopBar({
    Key? key,
    this.title = 'ValaisRoll',
    this.onBackButtonPressed,
    this.showConfirmationDialog = false,
    this.confirmationDialogText = 'Do you really want to leave this page? Any unsaved changes will be lost.',
    this.enableBackButton = true,
  }) : super(key: key);

  /// Checks if the current route matches the given route name.
  bool _isCurrentRoute(BuildContext context, String routeName) {
    return ModalRoute.of(context)?.settings.name == routeName;
  }

  /// Handles the back button press event.
  /// If [showConfirmationDialog] is true, shows a confirmation dialog before navigating back.
  Future<void> _handleBackButtonPressed(BuildContext context) async {
    if (showConfirmationDialog) {
      bool shouldLeave = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Exit'),
          content: Text(confirmationDialogText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (shouldLeave) {
        if (onBackButtonPressed != null) {
          onBackButtonPressed!();
        }
        Navigator.pop(context);
      }
    } else {
      if (onBackButtonPressed != null) {
        onBackButtonPressed!();
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canPop = Navigator.canPop(context); // Check if the current route can be popped

    return AppBar(
      title: Row(
        children: [
          Image.asset('assets/png/logo.png', width: 30, height: 30), // Display the logo
          const SizedBox(width: 8), // Add spacing between the logo and the title
          Text(title), // Display the title
        ],
      ),
      leading: (canPop && enableBackButton)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleBackButtonPressed(context),
              tooltip: 'Back',
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () async {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null && !_isCurrentRoute(context, '/account')) {
              Navigator.pushNamed(context, '/account');
            } else if (user == null && !_isCurrentRoute(context, '/login')) {
              Navigator.pushNamed(context, '/login');
            }
          },
          tooltip: 'Account',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Handle notifications
          },
          tooltip: 'Notifications',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'More options',
          onSelected: (String result) {
            if (result == 'privacy' && !_isCurrentRoute(context, '/privacy_policy')) {
              Navigator.pushNamed(context, '/privacy_policy');
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'privacy',
              child: Text('Privacy Policy'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Set the preferred size of the AppBar
}