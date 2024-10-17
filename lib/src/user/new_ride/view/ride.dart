import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // To track user's location
import 'package:valais_roll/src/user/new_ride/controller/bicycle_selection_controller.dart';
import 'package:valais_roll/src/widgets/button.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';

class Ride extends StatefulWidget {
  final LatLng startPoint;
  final LatLng destinationPoint;
  final String destinationName;
  final List<LatLng> waypoints; // Optional waypoints

  const Ride({
    super.key,
    required this.startPoint,
    required this.destinationPoint,
    required this.destinationName,
    this.waypoints = const [],
  });

  @override
  State<Ride> createState() => _RideState();
}

class _RideState extends State<Ride> {
  late GoogleMapController _mapController;
  late BicycleSelectionController _controller;
  StreamSubscription<Position>? _positionStreamSubscription;

  LatLng? _currentPosition;
  double? distance;
  String? duration;
  Set<Polyline> _polylines = {}; // Keep track of polylines

  @override
  void initState() {
    super.initState();
    _controller = BicycleSelectionController(
      startPoint: widget.startPoint,
      destinationPoint: widget.destinationPoint,
      mode: 'bicycling',
    );
    _fetchRouteInfo(); // Fetch the route info and polyline
    _fetchUserLocation(); // Fetch the user's current location
    _startPositionStream(); // Start listening to location updates
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // Cancel location updates when disposed
    super.dispose();
  }

  // Fetch the user's current location
  Future<void> _fetchUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // Center the map on the user's current location
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 14),
    );
  }

  // Start listening to location updates
  void _startPositionStream() {
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _updateDistanceAndDuration(); // Update distance and duration on every location update
    });
  }

  // Recalculate the distance and duration based on the user's current position
  Future<void> _updateDistanceAndDuration() async {
    if (_currentPosition == null) return;

    // Update only the distance and duration without recalculating the polylines
    _controller = BicycleSelectionController(
      startPoint: _currentPosition!,
      destinationPoint: widget.destinationPoint,
      mode: 'bicycling',
    );

    await _controller.getRouteInfo(widget.waypoints); // Fetch new distance and duration
    setState(() {
      distance = double.tryParse(_controller.totalDistance.replaceAll(' km', ''));
      duration = _controller.estimatedTime;
    });
  }

  // Fetch initial route information and polyline (called only once)
  Future<void> _fetchRouteInfo() async {
    await _controller.getRouteInfo(widget.waypoints);
    await _controller.getPolylineWithWaypoints(widget.waypoints);

    setState(() {
      distance = double.tryParse(_controller.totalDistance.replaceAll(' km', ''));
      duration = _controller.estimatedTime;
      _polylines = Set<Polyline>.of(_controller.polylines.values); // Store polylines initially
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Recenter the map on the user's current location
  void _recenterCamera() {
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 14),
      );
    }
  }

  // Function to handle the "Finish" button press
  void _finishRide() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ride finished.')),
    );
    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      isBottomNavBarEnabled: true,
      body: Column(
        children: [
          // Display distance and duration left
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
              children: [
                // Title
                Text(
                  'Ride to ${widget.destinationName}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // Distance and Time Left on the same row with spacing
                if (distance != null || duration != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0), // Add spacing between title and this row
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start, // Align items to the start (left)
                      children: [
                        if (distance != null)
                          Text(
                            "Distance left: ${distance!.toStringAsFixed(2)} km",
                            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                        if (distance != null && duration != null)
                          SizedBox(width: 16), // Add some spacing between Distance and Time
                        if (duration != null)
                          Text(
                            "Time left: $duration",
                            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Expanded Google Map displaying the route
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: widget.startPoint,
                    zoom: 14,
                  ),
                  polylines: _polylines, // Use the stored polylines
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
                    // Add waypoints if they exist
                    for (var waypoint in widget.waypoints)
                      Marker(
                        markerId: MarkerId(waypoint.toString()),
                        position: waypoint,
                        infoWindow: InfoWindow(title: 'Stopover'),
                      ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // Custom recenter button
                ),
                // Recenter button at the bottom left of the map
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: FloatingActionButton(
                    onPressed: _recenterCamera,
                    child: Icon(Icons.my_location),
                    mini: true,
                  ),
                ),
              ],
            ),
          ),
          // "Finish" button at the bottom right
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Button(
                text: "Finish",
                onPressed: _finishRide,
                isFilled: true,
                color: Theme.of(context).primaryColor,
                horizontalPadding: 20.0,
                verticalPadding: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
