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

  Future<void> _fetchRouteInfo() async {
    await _controller.getRouteInfo(waypoints);
    await _controller.getPolyline();
    setState(() {
      distance = double.tryParse(_controller.totalDistance.replaceAll(' km', ''));
      duration = _controller.estimatedTime;
    });
  }

  Future<void> _fetchPaymentMethod() async {
    PaymentMethodController paymentController = PaymentMethodController();
    String? paymentMethod = await paymentController.fetchPaymentMethod();

    setState(() {
      userPaymentMethod = paymentMethod;
      isLoadingPaymentMethod = false;
    });
  }

  Image? _getPaymentImage() {
    if (userPaymentMethod == 'none' || userPaymentMethod == null) {
      return null;
    }

    switch (userPaymentMethod) {
      case 'google_pay':
        return Image.asset('assets/png/googlePay.png', width: 30, height: 30);
      case 'credit_card':
        return Image.asset('assets/png/mastercard.png', width: 30, height: 30);
      case 'klarna':
        return Image.asset('assets/png/klarna.png', width: 30, height: 30);
      default:
        return null;
    }
  }

  Future<void> _handleStartRide() async {
    if (userPaymentMethod == 'none' || userPaymentMethod == null) {
      // Navigate to the payment selection page and await the result
      final selectedPaymentMethod = await Navigator.pushNamed(context, '/paymentApp');

      if (selectedPaymentMethod != null) {
        // Update the userPaymentMethod with the newly selected method and reload the UI
        setState(() {
          userPaymentMethod = selectedPaymentMethod.toString();
          _fetchPaymentMethod(); // Reload the payment method to reflect in the UI
        });
      }
    } else {
      // Proceed with starting the ride
      //******************************************************************** */
            //******************************************************************** */

      //******************************************************************** */

      //******************************************************************** */

      //******************************************************************** */

      //******************************************************************** */
    }
  }


  void _onMapTap(LatLng position) {
    setState(() {
      waypoints.clear();
      waypoints.add(position);
      waypointMarker = Marker(
        markerId: MarkerId('waypoint'),
        position: position,
        infoWindow: InfoWindow(title: 'Waypoint'),
      );
    });

    _controller.getPolylineWithWaypoints(waypoints).then((_) async {
      await _controller.getRouteInfo(waypoints);
      setState(() {
        distance =
            double.tryParse(_controller.totalDistance.replaceAll(' km', ''));
        duration = _controller.estimatedTime;
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
                Row(
                  children: [
                    Button(
                      text: "Cancel",
                      onPressed: () {
                        // Handle cancellation
                      },
                      isFilled: true,
                      color: Colors.red,
                      horizontalPadding: 20.0,
                      verticalPadding: 16.0,
                    ),
                    SizedBox(width: 10),
                    Button(
                      text: "Start Ride",
                      onPressed: _handleStartRide,
                      isFilled: true,
                      horizontalPadding: 20.0,
                      verticalPadding: 12.0,
                      image: _getPaymentImage(),
                      icon: userPaymentMethod == 'none' ? Icons.warning : null,
                    ),
                    SizedBox(width: 10),
                    // Add the info button with a tooltip for price info
                    Tooltip(
                      message: 'Price: 1 CHF per minute, minimum charge 5 CHF',
                      child: IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () {
                          // Show a SnackBar when the info button is clicked
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Price: 1 CHF per minute, minimum charge 5 CHF'),
                              duration: Duration(seconds: 3), 
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
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
                if (waypointMarker != null) waypointMarker!,
              },
            ),
          ),
        ],
      ),
    );
  }
}
