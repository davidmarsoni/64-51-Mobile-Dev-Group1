import 'package:flutter/material.dart';
import 'navigation_rail.dart'; // Update the path to the actual location of your NavigationRailComponent

class BasePage extends StatelessWidget {
  final Widget body;

  const BasePage({
    Key? key,
    required this.body,
  }) : super(key: key);

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