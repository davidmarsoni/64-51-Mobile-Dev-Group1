import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:valais_roll/src/new_ride/controller/bicycle_selection_controller.dart';
import 'package:valais_roll/src/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';
import 'package:valais_roll/src/payment/controller/payment_method_controller.dart'; // Import payment controller

class BicycleSelectionView extends StatefulWidget {
  final LatLng startPoint;
  final LatLng destinationPoint;

  const BicycleSelectionView({super.key, required this.startPoint, required this.destinationPoint});

  @override
  _BicycleSelectionViewState createState() => _BicycleSelectionViewState();
}

class _BicycleSelectionViewState extends State<BicycleSelectionView> {
  late BicycleSelectionController _controller;
  late GoogleMapController _mapController;

  String? userPaymentMethod;
  bool isLoadingPaymentMethod = true; // To show a loader while fetching

  @override
  void initState() {
    super.initState();
    _controller = BicycleSelectionController(
      startPoint: widget.startPoint,
      destinationPoint: widget.destinationPoint,
    );

    _fetchRouteInfo();
    _fetchPaymentMethod(); // Fetch payment method when initializing
  }

  // Fetch route information and polyline on initialization
  Future<void> _fetchRouteInfo() async {
    await _controller.getRouteInfo();
    await _controller.getPolyline();

    // Update the UI after fetching the route info and polylines
    setState(() {});
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

    // Display images based on the payment method
    switch (userPaymentMethod) {
      case 'Google Pay':
        return Image.asset('assets/png/googlePay.png', width: 30, height: 30);
      case 'Credit Card':
        return Image.asset('assets/png/mastercard.png', width: 30, height: 30);
      case 'Facturing (Klarna)':
        return Image.asset('assets/png/klarna.png', width: 30, height: 30);
      default:
        return null; // Fallback, no image for unknown payment methods
    }
  }

  // Method to handle payment method selection
  Future<void> _handleStartRide() async {
    if (userPaymentMethod == 'none' || userPaymentMethod == null) {
      // Navigate to payment method page and await the result
      final selectedPaymentMethod = await Navigator.pushNamed(context, '/paymentApp');

      // If the user selected a payment method, reload the page with the updated method
      if (selectedPaymentMethod != null) {
        setState(() {
          userPaymentMethod = selectedPaymentMethod.toString();
          _fetchPaymentMethod(); // Reload payment method after selection
        });
      }
    } else {
      // Proceed with the ride if a payment method exists
      // Handle the start ride logic here
      print('Starting ride with payment method: $userPaymentMethod');
    }
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
                    labelText: "Enter the bike code or take a photo of the QR code",
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
                      verticalPadding: 12.0,
                    ),
                    SizedBox(width: 10),
                    Button(
                      text: "Start Ride",
                      onPressed: _handleStartRide, // Call the method for handling
                      isFilled: true,
                      horizontalPadding: 20.0,
                      verticalPadding: 12.0,
                      image: _getPaymentImage(),
                      icon: userPaymentMethod == 'none' ? Icons.warning : null,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Estimated Time: ${_controller.estimatedTime}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Total Distance: ${_controller.totalDistance}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.startPoint,
                zoom: 13,
              ),
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
              },
              polylines: Set<Polyline>.of(_controller.polylines.values),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}
