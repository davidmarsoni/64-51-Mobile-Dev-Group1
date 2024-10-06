import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      case '/emergency_support':
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

          String targetRoute;
          switch (index) {
            case 0:
              targetRoute = '/itinerary';
              break;
            case 1:
              targetRoute = '/history';
              break;
            case 2:
              targetRoute = '/emergency_support';
              break;
            default:
              targetRoute = '/itinerary';
          }

          if (widget.currentRoute != targetRoute) {
            Navigator.pushReplacementNamed(context, targetRoute);
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