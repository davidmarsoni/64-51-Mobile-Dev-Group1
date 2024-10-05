import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:valais_roll/src/new_ride/controller/bicycle_selection_controller.dart';
import 'package:valais_roll/src/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';

class BicycleSelectionView extends StatefulWidget {
  final LatLng startPoint;
  final LatLng destinationPoint;

  const BicycleSelectionView({super.key, required this.startPoint, required this.destinationPoint});

  @override
  _BicycleSelectionViewState createState() => _BicycleSelectionViewState();
}

class _BicycleSelectionViewState extends State<BicycleSelectionView> {
  late BicycleSelectionController _controller;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _controller = BicycleSelectionController(
      startPoint: widget.startPoint,
      destinationPoint: widget.destinationPoint,
    );

    // Fetch route information and polyline on initialization
    _fetchRouteInfo();
  }

  Future<void> _fetchRouteInfo() async {
    await _controller.getRouteInfo();
    await _controller.getPolyline();

    // Update the UI after fetching the route info and polylines
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      isBottomNavBarEnabled: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select your bike",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text("Choose your bike", style: TextStyle(fontSize: 18)),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Enter the bike code or take a photo of the QR code",
                    suffixIcon: Icon(Icons.camera_alt),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                   Button(
                    text: "Cancel your booking",
                    onPressed: () {
                      // Handle cancellation
                    },
                    isFilled: true,
                    color: Colors.red,
                    horizontalPadding: 20.0,
                    verticalPadding: 12.0, 
                  ),
                  SizedBox(width: 10),
                  Button(
                    text: "Start your ride",
                    onPressed: () {
                      // Handle start ride
                    },
                    isFilled: true,
                    horizontalPadding: 20.0, 
                    verticalPadding: 12.0, 
                    icon: Icons.directions_bike,
                  ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Estimated Time: ${_controller.estimatedTime}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Total Distance: ${_controller.totalDistance}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.startPoint,
                zoom: 13,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('start'),
                  position: widget.startPoint,
                  infoWindow: InfoWindow(title: 'Start Point'),
                ),
                Marker(
                  markerId: MarkerId('destination'),
                  position: widget.destinationPoint,
                  infoWindow: InfoWindow(title: 'Destination'),
                ),
              },
              polylines: Set<Polyline>.of(_controller.polylines.values),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}