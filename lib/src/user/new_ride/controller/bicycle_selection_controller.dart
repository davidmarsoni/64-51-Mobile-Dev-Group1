import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

class BicycleSelectionController {
  final LatLng startPoint;
  final LatLng destinationPoint;
  final String mode; // Mode of transport (bicycling, driving, etc.)

  String estimatedTime = "Loading...";
  String totalDistance = "Loading...";
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  // Adding fields for distance and duration
  String? distance;
  String? duration;

  BicycleSelectionController({
    required this.startPoint,
    required this.destinationPoint,
    this.mode = 'bicycling', // default to bicycling
  });

  Future<void> getRouteInfo(List<LatLng>? waypoints) async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    String url;

    if (waypoints != null && waypoints.isNotEmpty) {
      // Create a string of waypoints for the request if available
      String waypointsStr = waypoints
          .map((point) => "${point.latitude},${point.longitude}")
          .join('|');

      // Build the URL for the Google Directions API with waypoints
      url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${startPoint.latitude},${startPoint.longitude}&destination=${destinationPoint.latitude},${destinationPoint.longitude}&waypoints=$waypointsStr&mode=$mode&key=$apiKey";
    } else {
      // Build the URL for the Google Directions API without waypoints
      url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${startPoint.latitude},${startPoint.longitude}&destination=${destinationPoint.latitude},${destinationPoint.longitude}&mode=$mode&key=$apiKey";
    }

    // Now you can make the API request as usual
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response
      var jsonData = json.decode(response.body);
      var routes = jsonData['routes'];

      if (routes.isNotEmpty) {
        var legs = routes[0]['legs'];
        
        // Clear previous duration and distance
        int totalDuration = 0;
        int totalDistance = 0;

        // Loop through all the legs (between start → waypoint(s) → destination)
        for (var leg in legs) {
          // Add duration and distance of each leg
          totalDuration += (leg['duration']['value'] as int);
          totalDistance += (leg['distance']['value'] as int);
        }

        // Convert to human-readable format (Google gives duration in seconds and distance in meters)
        duration = _formatDuration(totalDuration);
        distance = (totalDistance / 1000).toStringAsFixed(2) + ' km';

        // Update the estimatedTime and totalDistance fields
        estimatedTime = duration!;
        this.totalDistance = distance!;
      } else {
        print("No routes found.");
      }
    } else {
      print("Error fetching directions: ${response.statusCode}");
      estimatedTime = "Error";
      totalDistance = "Error";
    }
  }

  String _formatDuration(int durationInSeconds) {
    int hours = durationInSeconds ~/ 3600;
    int minutes = (durationInSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return "$hours h $minutes min";
    } else {
      return "$minutes min";
    }
  }


   Future<void> getPolyline() async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
 
    // Initialize PolylinePoints
    PolylinePoints polylinePoints = PolylinePoints();
 
    // Get the route between the start and destination points
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: PolylineRequest(
        origin: PointLatLng(startPoint.latitude, startPoint.longitude),
        destination:
            PointLatLng(destinationPoint.latitude, destinationPoint.longitude),
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

  Future<void> getPolylineWithWaypoints(List<LatLng> waypoints) async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
 
    PolylinePoints polylinePoints = PolylinePoints();
 
    // Create a string of waypoints for the request
    String waypointsStr = waypoints
        .map((point) => "${point.latitude},${point.longitude}")
        .join('|');
 
    // Get the route between the start, waypoints, and destination
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: PolylineRequest(
        origin: PointLatLng(startPoint.latitude, startPoint.longitude),
        destination:
            PointLatLng(destinationPoint.latitude, destinationPoint.longitude),
        wayPoints: waypoints
            .map((point) => PolylineWayPoint(
                location: "${point.latitude},${point.longitude}"))
            .toList(),
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
