import 'package:flutter/material.dart';
import 'package:valais_roll/src/new_ride/view/itinary_view.dart';
import 'package:valais_roll/src/others/emergency_support_page.dart'; // Import the emergency support page

class BottomNavBar extends StatefulWidget {
  final bool isEnabled;

  const BottomNavBar({super.key, required this.isEnabled});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) { // Assuming the "New ride" button is at index 1
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ItineraryPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: widget.isEnabled ? null : Colors.grey,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.search,
            color: widget.isEnabled ? null : Colors.grey,
          ),
          label: 'New ride',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: widget.isEnabled ? null : Colors.grey,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
