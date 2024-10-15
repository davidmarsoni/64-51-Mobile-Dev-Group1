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

  // Function to get distance, duration, and polyline route info using Google Directions API
  Future<void> getRouteInfo(List<LatLng> waypoints) async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

    // Create a string of waypoints for the request if available
    String waypointsStr = waypoints.isNotEmpty
        ? waypoints
            .map((point) => "${point.latitude},${point.longitude}")
            .join('|')
        : '';

    // Build the URL for the Google Directions API with optional waypoints
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startPoint.latitude},${startPoint.longitude}&destination=${destinationPoint.latitude},${destinationPoint.longitude}&waypoints=$waypointsStr&mode=$mode&key=$apiKey";

    // Make the request to the API
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response
      var jsonData = json.decode(response.body);
      var routes = jsonData['routes'];

      if (routes.isNotEmpty) {
        var legs = routes[0]['legs'][0];
        var durationText = legs['duration']['text'];
        var distanceText = legs['distance']['text'];

        // Update the duration and distance fields
        duration = durationText;
        distance = distanceText;

        // Update the estimatedTime and totalDistance fields
        estimatedTime = durationText;
        totalDistance = distanceText;

        // Clear previous coordinates
        polylineCoordinates.clear();

        // Add polyline coordinates from the steps
        var steps = legs['steps'];
        for (var step in steps) {
          var startLatLng = LatLng(step['start_location']['lat'], step['start_location']['lng']);
          var endLatLng = LatLng(step['end_location']['lat'], step['end_location']['lng']);
          polylineCoordinates.add(startLatLng);
          polylineCoordinates.add(endLatLng);
        }

        // Create a PolylineId and store the polyline
        PolylineId id = PolylineId("route_polyline");
        Polyline polyline = Polyline(
          polylineId: id,
          color: const Color(0xFF4285F4), // Customize the color if needed
          width: 5,
          points: polylineCoordinates,
        );
        polylines[id] = polyline;
      } else {
        print("No routes found.");
      }
    } else {
      print("Error fetching directions: ${response.statusCode}");
      estimatedTime = "Error";
      totalDistance = "Error";
    }
  }

  // Function to draw the route (polyline) including waypoints
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
