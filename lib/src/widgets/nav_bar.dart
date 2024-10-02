import 'package:flutter/material.dart';
import 'package:valais_roll/src/others/emergency_support_page.dart'; // Import the emergency support page

class BottomNavBar extends StatefulWidget {
  final bool isEnabled;

  const BottomNavBar({super.key, required this.isEnabled});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (int index) {
        if (widget.isEnabled) {
          setState(() {
            _currentIndex = index;
          });

          // Handle navigation based on selected index
          if (index == 2) {
            // Navigate to Emergency Support page if index is 2
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EmergencySupportPage()),
            );
          }
          // Add more navigation logic for other pages here if needed
        }
      },
      destinations: <NavigationDestination>[
        NavigationDestination(
          icon: Icon(
            Icons.directions_bike,
            color: widget.isEnabled ? null : Colors.grey,
          ),
          label: 'Your ride',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.search,
            color: widget.isEnabled ? null : Colors.grey,
          ),
          label: 'New ride',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.notifications,
            color: widget.isEnabled ? null : Colors.grey,
          ),
          label: 'Emergency Support',
        ),
      ],
    );
  }
}
