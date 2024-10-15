import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // For calculating distance
import 'package:valais_roll/src/user/new_ride/controller/itinary_controller.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:valais_roll/src/user/new_ride/controller/bicycle_selection_controller.dart';

class ItineraryStationView extends StatefulWidget {
  final String stationName;
  final LatLng stationPosition;

  const ItineraryStationView({
    super.key,
    required this.stationName,
    required this.stationPosition,
  });

  @override
  State<ItineraryStationView> createState() => _ItineraryStationViewState();
}

class _ItineraryStationViewState extends State<ItineraryStationView> {
  final Completer<GoogleMapController> _mapController = Completer();
  final ItineraryController _itineraryController = ItineraryController();
  StreamSubscription<Position>? _positionStreamSubscription;  // Stream subscription for location updates

  LatLng? _currentPosition;
  CameraPosition? _initialPosition;
  String selectedMode = 'walking'; // Default transportation mode
  String? _duration; // Store the duration of the journey
  static const double _arrivalThreshold = 50.0;
  bool _hasShownArrivalPopup = false; // Flag to track if the arrival popup has been shown

  // List of available transportation modes
  final Map<String, IconData> _transportationModes = {
    'walking': Icons.directions_walk,
    'bicycling': Icons.directions_bike,
    'driving': Icons.directions_car,
  };

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
    _startPositionStream();  // Start listening to location changes
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();  // Cancel the location updates stream on dispose
    _itineraryController.dispose();
    super.dispose();
  }

  // Fetch user's current position
  Future<void> _fetchUserLocation() async {
    await _itineraryController.getUserLocation(); // Ensure user location is fetched first
    LatLng? userLocation = await _itineraryController.getPosition();

    if (userLocation != null) {
      setState(() {
        _currentPosition = userLocation;
        _initialPosition = CameraPosition(target: userLocation, zoom: 14.0);
      });

      _startItinerary();
      _checkArrival();
    } else {
      _showErrorMessage("Unable to fetch current location.");
    }
  }

  // Start listening to location updates
  void _startPositionStream() {
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _checkArrival(); // Check arrival on every location update
    });
  }

  // Method to handle the "Start Itinerary" button
  Future<void> _startItinerary() async {
    if (_currentPosition != null) {
      // Clear the previous polylines before adding new ones
      setState(() {
        _itineraryController.polylines.clear(); // Clear the previous itinerary
      });

      // Fetch the duration and route info
      await _fetchRouteInfo();

      // Call the itinerary controller to fetch and draw the new route
      await _itineraryController.getRouteFromCurrentPosition(
        widget.stationPosition,
        selectedMode,
      );

      setState(() {
        // Update the UI once the new route is fetched and polylines are drawn
      });
    } else {
      _showErrorMessage("Current position not available.");
    }
  }

  // Fetch route info (duration, distance)
  Future<void> _fetchRouteInfo() async {
    if (_currentPosition != null) {
      // Create an instance of the BicycleSelectionController to get the route info
      final routeController = BicycleSelectionController(
        startPoint: _currentPosition!,
        destinationPoint: widget.stationPosition,
        mode: selectedMode, // Pass the selected mode
      );

      // Fetch the estimated time and distance
      await routeController.getRouteInfo();

      setState(() {
        _duration = routeController.estimatedTime;
      });
    }
  }

  // Check if the user has arrived at the station (within the proximity threshold)
  void _checkArrival() async {
    print('Checking for arrival...');
    if (_currentPosition != null && !_hasShownArrivalPopup) {
      // Calculate the distance between current position and the station
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        widget.stationPosition.latitude,
        widget.stationPosition.longitude,
      );

      print('Distance to station: $distance meters');

      // If the distance is less than the threshold, show arrival message
      if (distance <= _arrivalThreshold) {
        _showArrivalPopup();
        _hasShownArrivalPopup = true; // Set the flag to true
      }
    }
  }

  // Show the arrival popup
  void _showArrivalPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('You have arrived'),
          content: Text('You have arrived at ${widget.stationName}.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
              },
            ),
          ],
        );
      },
    );
  }

  // Method to update the mode of transportation and get the route
  void _updateTransportationMode(String mode) {
    setState(() {
      selectedMode = mode;
      _startItinerary(); // Fetch the route for the selected mode
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      isBottomNavBarEnabled: true,
      body: Stack(
        children: [
          Column(
            children: [
              // Title with station name and journey duration
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your journey to the station: ${widget.stationName}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (_duration != null)
                      Text(
                        'Estimated Duration: $_duration',
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),

              // Segmented buttons for transportation modes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SegmentedButton<String>(
                  segments: _transportationModes.keys.map((mode) {
                    return ButtonSegment<String>(
                      value: mode,
                      label: Text(mode),
                      icon: Icon(_transportationModes[mode]),
                    );
                  }).toList(),
                  selected: <String>{selectedMode}, // Only one mode can be selected at a time
                  onSelectionChanged: (Set<String> newSelection) {
                    _updateTransportationMode(newSelection.first);
                  },
                ),
              ),

              // The Map
              Expanded(
                child: _initialPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          _mapController.complete(controller);
                        },
                        initialCameraPosition: _initialPosition!,
                        markers: {
                          // Only show the selected station
                          Marker(
                            markerId: MarkerId(widget.stationName),
                            position: widget.stationPosition,
                            infoWindow: InfoWindow(title: widget.stationName),
                          ),
                        },
                        polylines: Set<Polyline>.of(_itineraryController.polylines.values),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapType: MapType.normal,
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 16,
            child: FloatingActionButton(
              heroTag: "recenterButton",
              onPressed: () async {
                LatLng? currentLocation = await _itineraryController.getPosition();
                if (currentLocation != null) {
                  final GoogleMapController controller = await _mapController.future;
                  controller.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: currentLocation, zoom: 14.0),
                  ));
                } else {
                  _showErrorMessage("Unable to fetch current location.");
                }
              },
              child: Icon(Icons.my_location),
              mini: true, // Optional to make it smaller
            ),
          ),
        ],
      ),
    );
  }

  // Show error messages
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }
}