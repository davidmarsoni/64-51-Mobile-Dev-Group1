import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:valais_roll/data/objects/history.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:valais_roll/data/repository/station_repository.dart';

class HistoryDetailPage extends StatefulWidget {
  final History history;

  HistoryDetailPage({Key? key, required this.history}) : super(key: key);

  @override
  _HistoryDetailPageState createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  double totalDistance = 0.0;
  int usageDurationMinutes = 0;
  double price = 0.0;
  final double ratePerMinute = 0.5; // Define the rate per minute

  String? startStationName;
  String? endStationName;

  @override
  void initState() {
    super.initState();
    _fetchStationNames();
    _getRouteWithWaypoints();
    _calculatePriceFromTime();
  }

  Future<void> _fetchStationNames() async {
    StationRepository stationRepo = StationRepository();

    var startStation = await stationRepo.getStationById(widget.history.startStationRef);
    var endStation = await stationRepo.getStationById(widget.history.endStationRef!);

    setState(() {
      startStationName = startStation?.name;
      endStationName = endStation?.name;
    });
  }

  Future<void> _getRouteWithWaypoints() async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    PolylinePoints polylinePoints = PolylinePoints();

    List<LatLng> waypoints = widget.history.interestPoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
    LatLng startPoint = LatLng(
      widget.history.startStationCoordinates?.latitude ?? 0,
      widget.history.startStationCoordinates?.longitude ?? 0,
    );
    LatLng destinationPoint = LatLng(
      widget.history.endStationCoordinates?.latitude ?? 0,
      widget.history.endStationCoordinates?.longitude ?? 0,
    );

    String waypointsStr = waypoints.isNotEmpty
        ? waypoints.map((point) => "${point.latitude},${point.longitude}").join('|')
        : '';

    String url = "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${startPoint.latitude},${startPoint.longitude}"
        "&destination=${destinationPoint.latitude},${destinationPoint.longitude}"
        "&waypoints=$waypointsStr"
        "&mode=bicycling&key=$apiKey";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        var points = data['routes'][0]['overview_polyline']['points'];
        List<PointLatLng> result = polylinePoints.decodePolyline(points);

        polylineCoordinates.clear();
        polylineCoordinates.addAll(result.map((point) => LatLng(point.latitude, point.longitude)));

        // Calculate distance
        _calculateTotalDistance();

        // Create a Polyline and add it to the map
        setState(() {
          PolylineId id = PolylineId("route");
          Polyline polyline = Polyline(
            polylineId: id,
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          );
          polylines[id] = polyline;
        });
      } else {
        print("No route found.");
      }
    } else {
      print("Failed to fetch route: ${response.statusCode}");
    }
  }

  void _calculateTotalDistance() {
    totalDistance = 0.0;
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }
    totalDistance = totalDistance / 1000; // Convert to km
  }

  void _calculatePriceFromTime() {
    try {
      DateTime? startTime = widget.history.startTime;
      DateTime? endTime = widget.history.endTime;

      if (startTime != null && endTime != null) {
        usageDurationMinutes = endTime.difference(startTime).inMinutes;
        price = usageDurationMinutes * ratePerMinute;
        if (price < 5) {
          price = 5;
        }
      } else {
        usageDurationMinutes = 0;
        price = 5;
      }
    } catch (e) {
      usageDurationMinutes = 0;
      price = 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialPosition = LatLng(
      widget.history.startStationCoordinates?.latitude ?? 0,
      widget.history.startStationCoordinates?.longitude ?? 0,
    );
    LatLng destinationPosition = LatLng(
      widget.history.endStationCoordinates?.latitude ?? 0,
      widget.history.endStationCoordinates?.longitude ?? 0,
    );

    Set<Marker> markers = {
      Marker(
        markerId: MarkerId('start'),
        position: initialPosition,
        infoWindow: const InfoWindow(title: 'Start Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      Marker(
        markerId: MarkerId('end'),
        position: destinationPosition,
        infoWindow: const InfoWindow(title: 'End Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    return BasePage(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Ride Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Display Start Station Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'From:',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                Text(
                  startStationName ?? 'Unknown',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Display End Station Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'To:',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                Text(
                  endStationName ?? 'Unknown',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Price:',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                Text(
                  'CHF ${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Duration:',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                Text(
                  '$usageDurationMinutes min',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Distance:',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                Text(
                  '${totalDistance.toStringAsFixed(2)} km',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialPosition,
                  zoom: 14,
                ),
                polylines: Set<Polyline>.of(polylines.values),
                markers: markers,
                myLocationEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  if (polylineCoordinates.isNotEmpty) {
                    LatLngBounds bounds = _calculateBounds(polylineCoordinates);
                    controller.animateCamera(
                      CameraUpdate.newLatLngBounds(bounds, 50),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double southWestLat =
        points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double southWestLng =
        points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double northEastLat =
        points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double northEastLng =
        points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }
}