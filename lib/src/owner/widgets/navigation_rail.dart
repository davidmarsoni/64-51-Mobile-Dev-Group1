import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavigationRailComponent extends StatefulWidget {
  @override
  _NavigationRailComponentState createState() => _NavigationRailComponentState();
}

class _NavigationRailComponentState extends State<NavigationRailComponent> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        bool isConnected = snapshot.hasData && snapshot.data != null;

        return NavigationRail(
          selectedIndex: 0,
          onDestinationSelected: isConnected
              ? (int index) {
                  // Handle navigation
                }
              : null,
          labelType: NavigationRailLabelType.all,
          destinations: [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard, color: isConnected ? null : Colors.grey),
              label: Text('Overview', style: TextStyle(color: isConnected ? null : Colors.grey)),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.directions_bike, color: isConnected ? null : Colors.grey),
              label: Text('Bikes', style: TextStyle(color: isConnected ? null : Colors.grey)),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.location_on, color: isConnected ? null : Colors.grey),
              label: Text('Stations', style: TextStyle(color: isConnected ? null : Colors.grey)),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people, color: isConnected ? null : Colors.grey),
              label: Text('Users', style: TextStyle(color: isConnected ? null : Colors.grey)),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.account_circle, color: isConnected ? null : Colors.grey),
              label: Text('Account', style: TextStyle(color: isConnected ? null : Colors.grey)),
            ),
          ],
        );
      },
    );
  }
}