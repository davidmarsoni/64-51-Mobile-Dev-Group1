import 'dart:convert';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

class BicycleSelectionController {
  final LatLng startPoint;
  final LatLng destinationPoint;
  final String mode; // Specify the mode

  String estimatedTime = "Loading...";
  String totalDistance = "Loading...";
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  BicycleSelectionController({
    required this.startPoint,
    required this.destinationPoint,
    this.mode = 'bicycling',
  });

  // Function to get distance and duration using Google Directions API and draw the polyline
  Future<void> getRouteInfo() async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

    // Build the URL for the Google Directions API
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startPoint.latitude},${startPoint.longitude}&destination=${destinationPoint.latitude},${destinationPoint.longitude}&mode=$mode&key=$apiKey";

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

        // Clear previous coordinates
        polylineCoordinates.clear();

        // Add polyline coordinates
        var steps = legs['steps'];
        for (var step in steps) {
          var startLatLng = LatLng(step['start_location']['lat'], step['start_location']['lng']);
          var endLatLng = LatLng(step['end_location']['lat'], step['end_location']['lng']);
          polylineCoordinates.add(startLatLng);
          polylineCoordinates.add(endLatLng);
        }

        // Create a PolylineId
        PolylineId id = PolylineId("route_polyline");
        Polyline polyline = Polyline(
          polylineId: id,
          color: const Color(0xFF4285F4), // Customize the color if needed
          width: 5,
          points: polylineCoordinates,
        );
        polylines[id] = polyline;
      }
    } else {
      print("Error fetching directions: ${response.statusCode}");
      estimatedTime = "Error";
      totalDistance = "Error";
    }
  }
}
