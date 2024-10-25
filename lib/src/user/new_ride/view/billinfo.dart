import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';
import 'package:valais_roll/src/user/new_ride/view/itinary_view.dart';
import 'package:valais_roll/data/enums/bikeState.dart';
import 'package:valais_roll/data/repository/bike_repository.dart';

class BillInfo extends StatelessWidget {
  final List<LatLng> userRoute;
  final BikeRepository bikeRepository = BikeRepository(); 
  final Bike bike;

  // Removed 'const' from constructor
  BillInfo({Key? key, required this.userRoute, required this.bike}) : super(key: key);

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Provide Feedback on Bike Condition',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Good Condition -> Sets status to available
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text(
                  'Good Condition',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  String resultMessage = await bikeRepository.setBikeStatusAvailable(bike.id!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Thank you for your feedback!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(),

              // Bad Condition -> Sets status to maintenance
              ListTile(
                leading: Icon(Icons.build, color: Colors.orange),
                title: Text(
                  'Bad Condition',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  String resultMessage = await bikeRepository.setBikeStatusMaintenance(bike.id!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Thank you for your feedback!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(),

              // Lost -> Sets status to lost
              ListTile(
                leading: Icon(Icons.error_outline, color: Colors.red),
                title: Text(
                  'Lost',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  String resultMessage = await bikeRepository.setBikeStatusLost(bike.id!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Thank you for your feedback!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialPosition = userRoute.isNotEmpty ? userRoute.first : LatLng(0, 0);
    LatLng destinationPosition = userRoute.isNotEmpty ? userRoute.last : LatLng(0, 0);

    Polyline userRoutePolyline = Polyline(
      polylineId: const PolylineId('user_route'),
      color: Colors.blue,
      width: 5,
      points: userRoute,
    );

    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: initialPosition,
        infoWindow: const InfoWindow(title: 'Start Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destinationPosition,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    double totalDistance = 0.0;
    for (int i = 0; i < userRoute.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        userRoute[i].latitude,
        userRoute[i].longitude,
        userRoute[i + 1].latitude,
        userRoute[i + 1].longitude,
      );
    }
    totalDistance = totalDistance / 1000;

    int estimatedDurationMinutes = (totalDistance * 12).toInt();
    double price = (estimatedDurationMinutes * 1).toDouble();
    if (price < 5) {
      price = 5;
    }

    LatLngBounds bounds;
    if (userRoute.isNotEmpty) {
      bounds = LatLngBounds(
        southwest: LatLng(
          userRoute.map((e) => e.latitude).reduce((value, element) => value < element ? value : element),
          userRoute.map((e) => e.longitude).reduce((value, element) => value < element ? value : element),
        ),
        northeast: LatLng(
          userRoute.map((e) => e.latitude).reduce((value, element) => value > element ? value : element),
          userRoute.map((e) => e.longitude).reduce((value, element) => value > element ? value : element),
        ),
      );
    } else {
      bounds = LatLngBounds(southwest: initialPosition, northeast: initialPosition);
    }

    return BasePage(
      isBottomNavBarEnabled: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Ride Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Price:',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                Text(
                  'CHF ${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Duration:',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                Text(
                  '$estimatedDurationMinutes min',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Distance:',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                Text(
                  '${totalDistance.toStringAsFixed(2)} km',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialPosition,
                  zoom: 14,
                ),
                polylines: {userRoutePolyline},
                markers: markers,
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Button(
                    text: 'Send Feedback',
                    onPressed: () => _showFeedbackDialog(context),
                    isFilled: false,
                    horizontalPadding: 45.0, // Slightly smaller than "Back home" button
                    verticalPadding: 12.0,
                  ),
                  const SizedBox(height: 8),
                  Button(
                    text: 'Back home',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ItineraryPage(),
                        ),
                      );
                    },
                    isFilled: true,
                    horizontalPadding: 60.0,
                    verticalPadding: 18.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
