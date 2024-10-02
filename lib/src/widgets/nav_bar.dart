import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valais_roll/src/others/emergency_support_page.dart'; // Import the emergency support page

class BottomNavBar extends StatefulWidget {
  final bool isEnabled;

  const BottomNavBar({
    super.key,
    required this.isEnabled,
  });

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    bool navBarEnabled = _currentUser != null && widget.isEnabled;

    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (int index) {
        if (navBarEnabled) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EmergencySupportPage()),
            );
          }
        }
      },
      destinations: <NavigationDestination>[
        NavigationDestination(
          icon: Icon(
            Icons.directions_bike,
            color: navBarEnabled ? null : Colors.grey,
          ),
          label: 'Your ride',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.search,
            color: navBarEnabled ? null : Colors.grey,
          ),
          label: 'New ride',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.notifications,
            color: navBarEnabled ? null : Colors.grey,
          ),
          label: 'Emergency Support',
        ),
      ],
    );
  }
}