import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';
import 'package:valais_roll/src/user/new_ride/view/itinary_view.dart';

class BillInfo extends StatelessWidget {
  final List<LatLng> userRoute;

  const BillInfo({Key? key, required this.userRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LatLng initialPosition = userRoute.isNotEmpty ? userRoute.first : LatLng(0, 0);
    LatLng destinationPosition = userRoute.isNotEmpty ? userRoute.last : LatLng(0, 0);

    // Create the polyline for the user's route
    Polyline userRoutePolyline = Polyline(
      polylineId: const PolylineId('user_route'),
      color: Colors.blue,
      width: 5,
      points: userRoute,
    );

    // Add markers for start and destination points
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

    // Calculate the distance traveled
    double totalDistance = 0.0;
    for (int i = 0; i < userRoute.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        userRoute[i].latitude,
        userRoute[i].longitude,
        userRoute[i + 1].latitude,
        userRoute[i + 1].longitude,
      );
    }
    totalDistance = totalDistance / 1000; // Convert meters to kilometers

    // Calculate the price (CHF 1 per minute, with a minimum of CHF 5)
    int estimatedDurationMinutes = (totalDistance * 12).toInt(); 
    double price = (estimatedDurationMinutes * 1).toDouble(); 
    if (price < 5) {
      price = 5; // Minimum price is CHF 5
    }

    // Calculate the LatLngBounds to fit the entire route on the map
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
                markers: markers, // Add markers to the map
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
            const SizedBox(height: 16), // Space between map and button
            Center(
              child: Button(
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
            ),
          ],
        ),
      ),
    );
  }
}
