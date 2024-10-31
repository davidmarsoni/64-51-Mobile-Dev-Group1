import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/repository/station_repository.dart';
import 'package:valais_roll/data/repository_manager.dart/trip_repository_manager.dart';
import 'package:valais_roll/src/user/new_ride/controller/bicycle_selection_controller.dart';
import 'package:valais_roll/src/user/new_ride/view/billinfo.dart';
import 'package:valais_roll/src/user/new_ride/view/payment.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class Ride extends StatefulWidget {
  final LatLng startPoint;
  final String startStationId;
  final LatLng destinationPoint;
  final String destinationStationId;
  final String destinationName;
  final List<LatLng> waypoints; 
  final Bike bike;
  String nearestStationId = ''; // Store the nearest station ID

  Ride({
    super.key,
    required this.startPoint,
    required this.startStationId,
    required this.destinationPoint,
    required this.destinationStationId,
    required this.destinationName,
    required this.waypoints,
    required this.bike, 
  });

  @override
  State<Ride> createState() => _RideState();
}

class _RideState extends State<Ride> {
  GoogleMapController? _mapController; // Make nullable
  late BicycleSelectionController _controller;
  StreamSubscription<Position>? _positionStreamSubscription;

  LatLng? _currentPosition;
  List<LatLng> _userPositions = []; // List to store user's position for pricing
  double? distance;
  String? duration;
  Set<Polyline> _polylines = {}; // Keep track of polylines
  Set<Marker> _markers = {}; // Store markers on the map
  LatLng? _nearestStation; // To store the nearest station position
  bool _rideFinished = false; // Track whether the ride has finished
  bool _isRidingToNearestStation = false;
  bool _isFinishButtonPressed = false;

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
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // Fetch the user's current location
  Future<void> _fetchUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _userPositions.add(_currentPosition!); // Store the first location
    });

    // Center the map on the user's current location
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 14),
    );
  }

void _startPositionStream() {
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      if (!mounted) return;
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _userPositions.add(_currentPosition!);
      });
 
      _updateDistanceAndDuration();
 
      if (_hasArrivedAtDestination()) {
        _showArrivalInfo();
        _positionStreamSubscription?.cancel();
      }
    });
  }

bool _hasArrivedAtDestination() {
    if (_currentPosition == null) return false;
 
    const double thresholdDistance = 25.0; // 25 meters threshold
 
    // Check if we are going to the final destination or nearest station
    LatLng targetPoint = _nearestStation ?? widget.destinationPoint;
 
    double distanceToTarget = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      targetPoint.latitude,
      targetPoint.longitude,
    );
 
    return distanceToTarget <= thresholdDistance;
  }


Future<void> _endRideAtNearestStation() async {
    await _findNearestStation();
    if (!mounted) return;
 
    if (_nearestStation != null && _currentPosition != null && _mapController != null) {
      _controller = BicycleSelectionController(
        startPoint: _currentPosition!,
        destinationPoint: _nearestStation!,
        mode: 'bicycling',
      );
 
      await _controller.getRouteInfo([]);
      await _controller.getPolylineWithWaypoints([]);
      
      if (!mounted) return;
 
      setState(() {
        _polylines = Set<Polyline>.of(_controller.polylines.values);
        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId('current_position'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: 'Your Position'),
        ));
        _markers.add(Marker(
          markerId: MarkerId('nearest_station'),
          position: _nearestStation!,
          infoWindow: InfoWindow(title: 'Nearest Station'),
        ));
 
        _isRidingToNearestStation = true;
        _rideFinished = false;
      });
 
      await _updateDistanceAndDuration();
      
      if (!mounted) return;
 
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          min(_currentPosition!.latitude, _nearestStation!.latitude),
          min(_currentPosition!.longitude, _nearestStation!.longitude),
        ),
        northeast: LatLng(
          max(_currentPosition!.latitude, _nearestStation!.latitude),
          max(_currentPosition!.longitude, _nearestStation!.longitude),
        ),
      );
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } else {
      _showErrorMessage("Unable to find the nearest station or get current position.");
    }
  }
void _showArrivalInfo() {
  // Terminate the current ride
  TripRepositoryManager tripRepositoryManager = TripRepositoryManager();
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    _showErrorMessage('User not logged in');
    return;
  }

  if (widget.bike.id == null) {
    _showErrorMessage('Bike ID is null');
    return;
  }

  // Use nearest station ID if available, otherwise use destination station ID
  String finalStationId = widget.nearestStationId.isNotEmpty 
      ? widget.nearestStationId 
      : widget.destinationStationId;

  tripRepositoryManager.endTrip(
    user.uid, 
    widget.bike.id!, 
    finalStationId
  ).then((_) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("You have arrived!"),
          content: Text("You have reached your destination. Your ride has ended."),
          actions: [
            TextButton(
              onPressed: () async {
                await _getPaymentMethod();
                if (mounted) {
                  Navigator.of(context).pop();
                  _navigateToBillInfo();
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }).catchError((error) {
    _showErrorMessage('Error ending trip: $error');
  });
}

  void _finishRide() {
    if (_isFinishButtonPressed) return; // Prevent further clicks

    setState(() {
      _isFinishButtonPressed = true; // Disable the button
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Finish Ride"),
          content: Text(
            "Are you sure you want to finish the ride? This will find the nearest station and guide you there. You will need to arrive at the station before the ride is considered finished.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isFinishButtonPressed = false; // Re-enable the button if canceled
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _endRideAtNearestStation(); // Find the nearest station and guide the user there
              },
              child: Text("Finish"),
            ),
          ],
        );
      },
    );
  }


  Future<void> _updateDistanceAndDuration() async {
    if (_currentPosition == null || !mounted) return;
 
    LatLng destination = _isRidingToNearestStation ? _nearestStation! : widget.destinationPoint;
 
    _controller = BicycleSelectionController(
      startPoint: _currentPosition!,
      destinationPoint: destination,
      mode: 'bicycling',
    );
 
    await _controller.getRouteInfo([]);
    if (!mounted) return;
    
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

      // Add initial markers
      _markers.add(Marker(
        markerId: MarkerId('start'),
        position: widget.startPoint,
        infoWindow: InfoWindow(title: 'Start Point'),
      ));

      _markers.add(Marker(
        markerId: MarkerId('destination'),
        position: widget.destinationPoint,
        infoWindow: InfoWindow(title: 'Destination'),
      ));

      // Add waypoints markers if exist
      for (var waypoint in widget.waypoints) {
        _markers.add(Marker(
          markerId: MarkerId(waypoint.toString()),
          position: waypoint,
          infoWindow: InfoWindow(title: 'Stopover'),
        ));
      }
    });
  }

  // Update onMapCreated to handle null safety
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  // Recenter the map on the user's current location
  void _recenterCamera() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 14),
      );
    }
  }

  // Function to find the nearest station
Future<void> _findNearestStation() async {
  if (_currentPosition == null || !mounted) return;

  try {
    StationRepository stationRepo = StationRepository();
    List<Station> stations = await stationRepo.getAllStations();
    
    if (!mounted) return;

    if (stations.isEmpty) {
      _showErrorMessage("No stations found");
      return;
    }

    print('Number of stations found: ${stations.length}');

    double shortestDistance = double.infinity;
    LatLng? nearestStationPosition;
    String? nearestStationId;

    for (var station in stations) {
      LatLng stationPosition = LatLng(
        station.coordinates.latitude,
        station.coordinates.longitude
      );

      double distanceToStation = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        stationPosition.latitude,
        stationPosition.longitude,
      );

      if (distanceToStation < shortestDistance) {
        shortestDistance = distanceToStation;
        nearestStationPosition = stationPosition;
        nearestStationId = station.id;
      }
    }

    if (nearestStationPosition != null && mounted) {
      setState(() {
        _nearestStation = nearestStationPosition;
        nearestStationId = nearestStationId;
      });
    } else {
      _showErrorMessage("No stations found.");
    }
  } catch (e) {
    _showErrorMessage("Error finding nearest station: $e");
  }
}

// Update the polyline to show the route from the current position to the nearest station
Future<void> _updatePolylineForNearestStation() async {
  if (_nearestStation != null) {
    setState(() {
      _rideFinished = true; // Mark the ride as finished
    });

    // Recalculate the route from current position to nearest station
    _controller = BicycleSelectionController(
      startPoint: _currentPosition!,
      destinationPoint: _nearestStation!,
      mode: 'bicycling',
    );

    await _controller.getPolylineWithWaypoints([]);
    setState(() {
      _polylines = Set<Polyline>.of(_controller.polylines.values); // Update polyline
    });
  }
}

// get users payment method from Firestore and display the payment page
Future<void> _getPaymentMethod() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User user = FirebaseAuth.instance.currentUser!;
  String userId = user.uid;
  DocumentSnapshot snapshot = await firestore.collection('users').doc(userId).get();

  if (snapshot.exists) {
    String? paymentMethod = snapshot.get('payment_data.payment_method');

    if (paymentMethod != null) {
      Payment.show(context, paymentMethod: paymentMethod);
    } else {
      _showErrorMessage('No payment method found');
    }
  } else {
    _showErrorMessage('User data not found');
  }
}

// Function to navigate to BillInfo page
void _navigateToBillInfo() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BillInfo(
        userRoute: _userPositions,
        bike: widget.bike, // Pass the bike with its ID
      ),
    ),
  );
}

  // Helper function to create LatLngBounds from a list of LatLngs
  LatLngBounds _createBoundsFromPositions(List<LatLng> positions) {
    assert(positions.isNotEmpty);

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var position in positions) {
      if (position.latitude < minLat) minLat = position.latitude;
      if (position.latitude > maxLat) maxLat = position.latitude;
      if (position.longitude < minLng) minLng = position.longitude;
      if (position.longitude > maxLng) maxLng = position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Show error messages
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
Widget build(BuildContext context) {
  return BasePage(
    enableBackButton: false,
    isBottomNavBarEnabled: true,
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isRidingToNearestStation
                    ? 'Ride to Nearest Station'
                    : 'Ride to ${widget.destinationName}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (distance != null || duration != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (distance != null)
                        Text(
                          "Distance left: ${distance!.toStringAsFixed(2)} km",
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                      if (distance != null && duration != null)
                        SizedBox(width: 16),
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
                  markers: _markers, // Display the markers
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // Custom recenter button
                ),
                // Center the "Finish" button horizontally at the bottom
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton.extended(
                      onPressed: _isFinishButtonPressed ? null : _finishRide, // Disable button if already pressed
                      label: Text("Finish"),
                      icon: Icon(Icons.check),
                      backgroundColor: _isFinishButtonPressed ? Colors.grey : null, // Change color if disabled
                    ),
                  ),
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
        ],
      ),
    );
  }
}
