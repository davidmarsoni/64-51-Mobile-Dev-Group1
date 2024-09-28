import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final bool isEnabled;

  const BottomNavBar({Key? key, required this.isEnabled}) : super(key: key);

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