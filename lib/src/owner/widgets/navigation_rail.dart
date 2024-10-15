import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavigationRailComponent extends StatefulWidget {
  const NavigationRailComponent({super.key});

  @override
  _NavigationRailComponentState createState() => _NavigationRailComponentState();
}

class _NavigationRailComponentState extends State<NavigationRailComponent> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/owner_dashboard',
    '/owner_bike',
    '/owner_station',
    '/owner_user',
    '/owner_account',
  ];

  bool _isCurrentRoute(String routeName) {
    return ModalRoute.of(context)?.settings.name == routeName;
  }

  void _onDestinationSelected(int index) {
    if (!_isCurrentRoute(_routes[index])) {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.pushNamed(context, _routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        bool isConnected = snapshot.hasData && snapshot.data != null;

        if (!isConnected) {
          return Container(); // Return an empty container when the user is not connected
        }

        return NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard),
              label: Text('Overview'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.directions_bike),
              label: Text('Bikes'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.location_on),
              label: Text('Stations'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people),
              label: Text('Users'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.account_circle),
              label: Text('Account'),
            ),
          ],
        );
      },
    );
  }
}