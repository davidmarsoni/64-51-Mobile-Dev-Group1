import 'package:flutter/material.dart';
import 'package:valais_roll/src/widgets/nav_bar.dart';
import 'package:valais_roll/src/widgets/top_bar.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final bool isBottomNavBarEnabled;

  const BasePage({
    this.title = 'ValaisRoll',
    required this.body,
    this.isBottomNavBarEnabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: title),
      body: body,
      bottomNavigationBar: BottomNavBar(
        isEnabled: isBottomNavBarEnabled,
        currentRoute: ModalRoute.of(context)?.settings.name ?? '/',
      ),
    );
  }
}