import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:valais_roll/src/user/new_ride/controller/bicycle_selection_controller.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';
import 'package:valais_roll/src/user/payment/controller/payment_method_controller.dart';

class BicycleSelectionView extends StatefulWidget {
  final LatLng startPoint;
  final LatLng destinationPoint;

  const BicycleSelectionView(
      {super.key, required this.startPoint, required this.destinationPoint});

  @override
  _BicycleSelectionViewState createState() => _BicycleSelectionViewState();
}

class _BicycleSelectionViewState extends State<BicycleSelectionView> {
  late BicycleSelectionController _controller;
  late GoogleMapController _mapController;
  Marker? waypointMarker; // Marqueur unique pour le waypoint

  String? userPaymentMethod;
  bool isLoadingPaymentMethod = true; // To show a loader while fetching
  List<LatLng> waypoints = []; // List to store waypoints
  double? distance; // To store the calculated distance
  String? duration; // To store the calculated duration

  @override
  void initState() {
    super.initState();
    _controller = BicycleSelectionController(
      startPoint: widget.startPoint,
      destinationPoint: widget.destinationPoint,
      mode: 'bicycling', // Explicitly set the mode to 'bicycling'
    );

    _fetchRouteInfo();
    _fetchPaymentMethod(); // Fetch payment method when initializing
  }

  // Fetch route information and polyline on initialization
  Future<void> _fetchRouteInfo() async {
    // Call getRouteInfo with the current waypoints (empty initially)
    await _controller.getRouteInfo(waypoints);

    // Fetch the polyline after getting the route info
    await _controller.getPolyline();

    // Update the UI after fetching the route info and polylines
    setState(() {
      distance =
          double.tryParse(_controller.totalDistance.replaceAll(' km', ''));
      duration = _controller.estimatedTime;
    });
  }


  // Fetch the user's payment method from the database
  Future<void> _fetchPaymentMethod() async {
    PaymentMethodController paymentController = PaymentMethodController();
    String? paymentMethod = await paymentController.fetchPaymentMethod();

    setState(() {
      userPaymentMethod = paymentMethod;
      isLoadingPaymentMethod = false; // Stop loading once payment method is fetched
    });
  }

  // Helper method to return the appropriate image based on the payment method
  Image? _getPaymentImage() {
    if (userPaymentMethod == 'none' || userPaymentMethod == null) {
      return null; // No image when there's no payment method, use an Icon fallback
    }

    debugPrint('Payment method: $userPaymentMethod');
    debugPrint('Payment method: $userPaymentMethod');
    debugPrint('Payment method: $userPaymentMethod');
    debugPrint('Payment method: $userPaymentMethod');
    debugPrint('Payment method: $userPaymentMethod');

    // Display images based on the payment method
    switch (userPaymentMethod) {
      case 'google_pay':
        return Image.asset('assets/png/googlePay.png', width: 30, height: 30);
      case 'credit_card':
        return Image.asset('assets/png/mastercard.png', width: 30, height: 30);
      case 'klarna':
        debugPrint('AAA');
         debugPrint('AAA');
        return Image.asset('assets/png/klarna.png', width: 30, height: 30);
      default:
       debugPrint('BBB');
        debugPrint('BBB');
        return null; // Fallback, empty widget for unknown payment methods
    }
  }

  // Method to handle payment method selection
  Future<void> _handleStartRide() async {
    if (userPaymentMethod == 'none' || userPaymentMethod == null) {
      final selectedPaymentMethod =
          await Navigator.pushNamed(context, '/paymentApp');

      if (selectedPaymentMethod != null) {
        setState(() {
          userPaymentMethod = selectedPaymentMethod.toString();
          _fetchPaymentMethod(); // Reload payment method after selection
        });
      }
    } else {
      // Handle the start ride logic here
      print('Starting ride with payment method: $userPaymentMethod');
    }
  }

// Handle map tap to add a waypoint and recalculate the route
  void _onMapTap(LatLng position) {
    setState(() {
      // Clear the previous waypoints and add the new tapped position
      waypoints.clear();
      waypoints.add(position); // Ajoutez le waypoint à l'emplacement cliqué

      // Créez un nouveau marqueur pour le waypoint
      waypointMarker = Marker(
        markerId: MarkerId('waypoint'), // ID fixe pour le waypoint
        position: position,
        infoWindow: InfoWindow(title: 'Waypoint'),
      );
    });

    // Update the polyline with the new waypoints and recalculate distance/time
    _controller.getPolylineWithWaypoints(waypoints).then((_) async {
      // Fetch the updated route information with the new waypoint
      await _controller.getRouteInfo(waypoints); // Pass the waypoints

      // Update distance and duration based on the fetched route
      setState(() {
        distance =
            double.tryParse(_controller.totalDistance.replaceAll(' km', ''));
        duration = _controller.estimatedTime; // Get the updated duration
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      isBottomNavBarEnabled: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select your bike",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text("Choose your bike", style: TextStyle(fontSize: 18)),
                TextField(
                  decoration: InputDecoration(
                    labelText:
                        "Enter the bike code or take a photo of the QR code",
                    suffixIcon: Icon(Icons.camera_alt),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _handleStartRide,
                  child: Text("Start Ride"),
                ),
                SizedBox(height: 10),
                // Display distance and duration in a compact style
                if (distance != null && duration != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Distance: ${distance!.toStringAsFixed(2)} km",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Duration: $duration",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: widget.startPoint,
                zoom: 14,
              ),
              onTap: _onMapTap,
              polylines: Set<Polyline>.of(_controller.polylines.values),
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
                // Ajoutez le marqueur du waypoint si présent
                if (waypointMarker != null) waypointMarker!,
              },
            ),
          ),
        ],
      ),
    );
  }
}
