import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackButtonPressed;
  final bool showConfirmationDialog;
  final String confirmationDialogText;
  final bool enableBackButton; // New parameter

  const TopBar({
    Key? key,
    this.title = 'ValaisRoll',
    this.onBackButtonPressed,
    this.showConfirmationDialog = false,
    this.confirmationDialogText = 'Do you really want to leave this page? Any unsaved changes will be lost.',
    this.enableBackButton = true, // Default to true
  }) : super(key: key);

  bool _isCurrentRoute(BuildContext context, String routeName) {
    return ModalRoute.of(context)?.settings.name == routeName;
  }

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
    bool canPop = Navigator.canPop(context);

    return AppBar(
      title: Row(
        children: [
          Image.asset('assets/png/logo.png', width: 30, height: 30),
          const SizedBox(width: 8),
          Text(title),
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}