import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A bottom navigation bar widget that provides navigation between different routes.
/// It also checks if the user is authenticated and whether the navigation bar is enabled.
class BottomNavBar extends StatefulWidget {
  final bool isEnabled; // Whether the bottom navigation bar is enabled
  final String currentRoute; // The current route of the application

  /// Creates a [BottomNavBar] widget.
  ///
  /// The [isEnabled] and [currentRoute] parameters are required.
  const BottomNavBar({
    super.key,
    required this.isEnabled,
    required this.currentRoute,
  });

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex; // The current index of the selected navigation item
  User? _currentUser; // The current authenticated user

  @override
  void initState() {
    super.initState();
    _currentIndex = _getIndexFromRoute(widget.currentRoute); // Initialize the current index based on the route
    _currentUser = FirebaseAuth.instance.currentUser; // Get the current authenticated user
  }

  /// Returns the index of the navigation item based on the route.
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
    // Determine if the navigation bar should be enabled
    bool navBarEnabled = _currentUser != null && widget.isEnabled;

    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (int index) {
        if (navBarEnabled) {
          setState(() {
            _currentIndex = index; // Update the current index
          });

          // Determine the target route based on the selected index
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

          // Navigate to the target route if it is different from the current route
          if (widget.currentRoute != targetRoute) {
            Navigator.pushReplacementNamed(context, targetRoute);
          }
        }
      },
      destinations: <NavigationDestination>[
        NavigationDestination(
          icon: Icon(
            Icons.search,
            color: navBarEnabled ? null : Colors.grey, // Change color based on navBarEnabled
          ),
          label: 'New ride',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.directions_bike,
            color: navBarEnabled ? null : Colors.grey, // Change color based on navBarEnabled
          ),
          label: 'Your rides',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.notifications,
            color: navBarEnabled ? null : Colors.grey, // Change color based on navBarEnabled
          ),
          label: 'Emergency Support',
        ),
      ],
    );
  }
}