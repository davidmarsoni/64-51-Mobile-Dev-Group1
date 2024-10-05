import 'package:flutter/material.dart';
import 'package:valais_roll/src/new_ride/view/itinary_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valais_roll/src/others/emergency_support_page.dart';

class BottomNavBar extends StatefulWidget {
  final bool isEnabled;
  final String currentRoute;

  const BottomNavBar({
    super.key,
    required this.isEnabled,
    required this.currentRoute,
  });

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentIndex = _getIndexFromRoute(widget.currentRoute);
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  int _getIndexFromRoute(String route) {
    switch (route) {
      case '/itinerary':
        return 0;
      case '/history':
        return 1;
      case '/emergencySupport':
        return 2;
      default:
        return 0;
    }
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
          if(index == 0) {
            Navigator.pushReplacementNamed(context, '/itinerary');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/history');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/emergencySupport');
          }
        }
      },
      destinations: <NavigationDestination>[
        NavigationDestination(
          icon: Icon(
            Icons.search,
            color: navBarEnabled ? null : Colors.grey,
          ),
          label: 'New ride',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.directions_bike,
            color: navBarEnabled ? null : Colors.grey,
          ),
          label: 'Your rides',
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