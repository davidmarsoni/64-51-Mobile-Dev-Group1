import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; 
import 'package:http/http.dart' as http;

class BicycleSelectionController {
  final LatLng startPoint;
  final LatLng destinationPoint;

  String estimatedTime = "Loading...";
  String totalDistance = "Loading...";
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  BicycleSelectionController({required this.startPoint, required this.destinationPoint});

  // Function to get distance and duration using Google Directions API
  Future<void> getRouteInfo() async {
    String apiKey = "GOOGLEAPIKEY";  

    // Build the URL for the Google Directions API
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startPoint.latitude},${startPoint.longitude}&destination=${destinationPoint.latitude},${destinationPoint.longitude}&mode=bicycling&key=$apiKey";

    // Make the request to the API
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response
      var jsonData = json.decode(response.body);
      var routes = jsonData['routes'];

      if (routes.isNotEmpty) {
        var legs = routes[0]['legs'][0]; 
        var duration = legs['duration']['text']; 
        var distance = legs['distance']['text']; 
        estimatedTime = duration; 
        totalDistance = distance; 
      }
    } else {
      print("Error fetching directions: ${response.statusCode}");
      estimatedTime = "Error";
      totalDistance = "Error";
    }
  }

  // Function to draw the route (polyline) between start and destination
  Future<void> getPolyline() async {
    String apiKey = "GOOGLEAPIKEY"; 

    // Initialize PolylinePoints
    PolylinePoints polylinePoints = PolylinePoints();

    // Get the route between the start and destination points
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: PolylineRequest(
        origin: PointLatLng(startPoint.latitude, startPoint.longitude),
        destination: PointLatLng(destinationPoint.latitude, destinationPoint.longitude),
        mode: TravelMode.bicycling,
      ),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      // Create a PolylineId
      PolylineId id = PolylineId("poly");
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5,
      );
      polylines[id] = polyline;
    } else {
      print("No route found or error: ${result.errorMessage}");
    }
  }
}
