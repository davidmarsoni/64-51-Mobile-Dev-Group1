import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TopBar({super.key, this.title = 'ValaisRoll'});

  bool _isCurrentRoute(BuildContext context, String routeName) {
    return ModalRoute.of(context)?.settings.name == routeName;
  }

  @override
  Widget build(BuildContext context) {
    bool canPop = Navigator.canPop(context);

    return AppBar(
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/svg/logo.svg', // Path to your logo image
            height: 24, // Adjust the height as needed
          ),
          const SizedBox(width: 8), // Add some space between the logo and the title
          Text(title),
        ],
      ),
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
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
            // Implement your logic here
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