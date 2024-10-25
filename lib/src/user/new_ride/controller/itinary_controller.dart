import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For Google API key
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/data/repository/station_repository.dart';

class ItineraryController {
  final loc.Location _locationController = loc.Location();
  final List<String> _stationNames = [];
  LatLng? _currentP;
  List<Marker> _markers = [];
  List<String> _suggestedStations = [];
  Map<PolylineId, Polyline> polylines = {};
  List<Marker> get markers => _markers;
  List<String> get suggestedStations => _suggestedStations;

  final StationRepository _stationRepository = StationRepository();

  // Stream controllers for location and markers updates
  final StreamController<List<Marker>> _markersController =
      StreamController<List<Marker>>.broadcast();
  Stream<List<Marker>> get markersStream => _markersController.stream;

  final StreamController<LatLng?> _locationControllerStream =
      StreamController<LatLng?>.broadcast();
  Stream<LatLng?> get locationStream => _locationControllerStream.stream;

  // Flag to track if the controller is disposed
  bool _isDisposed = false;

  //getter for stationnames
  List<String> get stationNames => _stationNames.map((name) => name.toLowerCase()).toList();

  Future<void> getUserLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    // Ensure that the location service is enabled
    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return;
      }
    }

    // Check for location permissions
    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        print("Location permissions are denied.");
        return;
      }
    }

    // Fetch the current location
    loc.LocationData locationData = await _locationController.getLocation();
    _currentP = LatLng(locationData.latitude!, locationData.longitude!);

    // Notify listeners that the current position is available
    if (!_isDisposed) {
      _locationControllerStream.add(_currentP);
    }
  }

  Future<LatLng> getPosition() async {
    loc.LocationData locationData = await _locationController.getLocation();
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

   Future<void> fetchStations() async {
    List<Station> stations = await _stationRepository.getAllStations();
    List<Marker> markers = await Future.wait(stations.map((station) async {
      GeoPoint geoPoint = station.coordinates;
      String stationName = station.name!.toLowerCase().trim(); // Ensure lowercase and trim spaces
      _stationNames.add(stationName);
      int nbrBicycles = await _stationRepository.countAvailableBikes(station.id!);
      
      return Marker(
        markerId: MarkerId(station.id!),
        position: LatLng(geoPoint.latitude, geoPoint.longitude),
        infoWindow: InfoWindow(
          title: '${station.name} | $nbrBicycles bicycles',
          snippet: station.address,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
    }).toList());
    _markers = markers;
    if (!_isDisposed) {
      _markersController.add(_markers);
    }
  }

  // Method to calculate the route and polyline between the user's current position and a station
  Future<void> getRouteFromCurrentPosition(LatLng destinationPoint, String mode) async {
    if (_currentP == null) {
      print("Current position not available.");
      return;
    }

    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print("API Key is missing!");
    }

    // Initialize PolylinePoints for generating polylines
    PolylinePoints polylinePoints = PolylinePoints();

    TravelMode _getTravelMode(String mode) {
      switch (mode) {
        case 'walking':
          return TravelMode.walking;
        case 'driving':
          return TravelMode.driving;
        case 'bicycling':
          return TravelMode.bicycling;
        default:
          return TravelMode.driving;
      }
    }

    // Get the route between the current position and the selected station based on the selected mode
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: PolylineRequest(
        origin: PointLatLng(_currentP!.latitude, _currentP!.longitude),
        destination: PointLatLng(destinationPoint.latitude, destinationPoint.longitude),
        mode: _getTravelMode(mode),
      ),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = [];
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      // Create a PolylineId
      PolylineId id = PolylineId("route_from_current_$mode");
      Polyline polyline = Polyline(
        polylineId: id,
        color: const Color(0xFF4285F4), // Customize color here
        width: 5,
        points: polylineCoordinates,
      );
      polylines[id] = polyline;

      // Notify listeners about the new polyline
      if (!_isDisposed) {
        _markersController.add(_markers);
      }
    } else {
      print("No route found or error: ${result.errorMessage}");
    }
  }

  Future<bool> capacity(String stationName) async {
    try {
      print(stationName);
      // Query Firestore for the station document with the given name
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('stations')
          .where('Name', isEqualTo: stationName.trim())
          .get();

      // Check if any station was found
      if (snapshot.docs.isEmpty) {
        print("No station found with the name $stationName");
        return false;
      }

      // Extract the number of bicycles from the station's document
      DocumentSnapshot stationDoc = snapshot.docs.first;
      int nbrBicycles = stationDoc['NbrBicycle'];

      // Return true if there are more than 0 bicycles, false otherwise
      return nbrBicycles > 0;
    } catch (e) {
      print("Error checking capacity: $e");
      return false;
    }
  }

  void onTextChanged(String searchText, bool isStart) {
    _suggestedStations = _stationNames
        .where((station) =>
            station.toLowerCase().startsWith(searchText.toLowerCase()))
        .toList();
  }

  void dispose() {
    _isDisposed = true;
    _markersController.close();
    _locationControllerStream.close();
  }

}