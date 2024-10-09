import 'package:flutter/material.dart';
import 'navigation_rail.dart'; // Update the path to the actual location of your NavigationRailComponent

class BasePage extends StatelessWidget {
  final Widget body;

  const BasePage({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRailComponent(),
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}