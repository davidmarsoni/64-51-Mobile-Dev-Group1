import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencySupportPage extends StatelessWidget {
  const EmergencySupportPage({super.key});

  // Function to make a real phone call using a valid Swiss number or simulate for web
  void _makePhoneCall(BuildContext context, String number) async {
    if (kIsWeb) {
      // If running on web, show a dialog instead of launching a phone call
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Simulated Call'),
            content: Text('This is a simulated call to $number.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      final Uri url = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New title
            const Text(
              'Emergency Support',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8), // Space between titles
            const Text(
              'Are you in emergency?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 10), // Space between texts
            const Text(
              'Press the button depending on your emergency',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20), // Space before the buttons

            // Emergency buttons
            Expanded(
              child: ListView(
                children: [
                  // Hospital Button
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.call, color: Colors.white),
                      ),
                      title: const Text('Hospital'),
                      subtitle: const Text('144'),
                      onTap: () => _makePhoneCall(context,
                          '+41001'), // Simulated format for Swiss Hospital emergency number
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Police Button
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.call, color: Colors.white),
                      ),
                      title: const Text('Police'),
                      subtitle: const Text('117'),
                      onTap: () => _makePhoneCall(context,
                          '+41002'), // Simulated format for Swiss Police emergency number
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Firefighter Button
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.call, color: Colors.white),
                      ),
                      title: const Text('Firefighter'),
                      subtitle: const Text('118'),
                      onTap: () => _makePhoneCall(context,
                          '+41003'), // Simulated format for Swiss Firefighter emergency number
                    ),
                  ),
                ],
              ),
            ),

            /*
            // User Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent),
              ),
              child: Column(
                children: [
                  const Text('Your location',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    'Location: $userLocation',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            */
          ],
        ),
      ),
      isBottomNavBarEnabled: true,
    );
  }
}