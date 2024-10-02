import 'package:flutter/material.dart';
import 'package:valais_roll/src/widgets/base_page.dart';

class EmergencySupportPage extends StatelessWidget {
  const EmergencySupportPage({super.key});

  // Function to simulate a phone call
  void _simulatePhoneCall(
      BuildContext context, String serviceName, String number) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Calling $serviceName'),
          content: Text(
              'This is a simulated call to $serviceName at number $number.'),
          actions: <Widget>[
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
  }

  @override
  Widget build(BuildContext context) {
    String userLocation =
        "123 Main St, Springfield"; // Replace with the actual location

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
              'Press the button depending your emergency',
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
                      onTap: () => _simulatePhoneCall(
                          context, 'Hospital', '144'), // Simulate hospital call
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
                      onTap: () => _simulatePhoneCall(
                          context, 'Police', '117'), // Simulate police call
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
                      onTap: () => _simulatePhoneCall(context, 'Firefighter',
                          '118'), // Simulate firefighter call
                    ),
                  ),
                  const SizedBox(height: 20), // Space before user info box
                ],
              ),
            ),

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
          ],
        ),
      ),
      isBottomNavBarEnabled: true,
    );
  }
}