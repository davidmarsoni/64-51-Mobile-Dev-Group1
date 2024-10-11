import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class ItineraryController {
  final loc.Location _locationController = loc.Location();
  final List<String> _stationNames = [];
  LatLng? _currentP;
  List<Marker> _markers = [];
  List<String> _suggestedStations = [];
  Map<PolylineId, Polyline> polylines = {};
  List<Marker> get markers => _markers;
  List<String> get suggestedStations => _suggestedStations;

  // Stream controllers for location and markers updates
  final StreamController<List<Marker>> _markersController = StreamController<List<Marker>>.broadcast();
  Stream<List<Marker>> get markersStream => _markersController.stream;

  final StreamController<LatLng?> _locationControllerStream = StreamController<LatLng?>.broadcast();
  Stream<LatLng?> get locationStream => _locationControllerStream.stream;

  // Flag to track if the controller is disposed
  bool _isDisposed = false;

  //getter for stationnames
  //List<String> get stationNames => _stationNames to lower case
  List<String> get stationNames => _stationNames.map((name) => name.toLowerCase()).toList();

  Future<void> getUserLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    loc.LocationData locationData = await _locationController.getLocation();
    _currentP = LatLng(locationData.latitude!, locationData.longitude!);
    if (!_isDisposed) {
      _locationControllerStream.add(_currentP);
    }
  }

  Future<LatLng> getPosition() async {
    loc.LocationData locationData = await _locationController.getLocation();
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  Future<void> fetchStations() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('stations').get();
    List<Marker> markers = snapshot.docs.map((doc) {
      GeoPoint geoPoint = doc['Geopoint'];
      String stationName = doc['Name'].toLowerCase().trim();  // Ensure lowercase and trim spaces
      _stationNames.add(stationName);

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(geoPoint.latitude, geoPoint.longitude),
        infoWindow: InfoWindow(
          title: '${doc['Name']} | ${doc['NbrBicycle']} Bicycles',
          snippet: doc['Description'],
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
    }).toList();
    _markers = markers;
    if (!_isDisposed) {
      _markersController.add(_markers);
    }
  }

  void onTextChanged(String searchText, bool isStart) {
    _suggestedStations = _stationNames
        .where((station) => station.toLowerCase().startsWith(searchText.toLowerCase()))
        .toList();
  }

  void dispose() {
    _isDisposed = true;
    _markersController.close();
    _locationControllerStream.close();
  }
}