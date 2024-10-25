import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/src/user/new_ride/controller/bicycle_selection_controller.dart';
import 'package:valais_roll/src/user/new_ride/view/ride.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';
import 'package:valais_roll/src/user/payment/controller/payment_method_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore import

class BicycleSelectionView extends StatefulWidget {
  final LatLng startPoint;
  final LatLng destinationPoint;
  final String destinationName;

  const BicycleSelectionView(
      {super.key, required this.startPoint, required this.destinationPoint, required this.destinationName});

  @override
  _BicycleSelectionViewState createState() => _BicycleSelectionViewState();
}

class _BicycleSelectionViewState extends State<BicycleSelectionView> {
  late BicycleSelectionController _controller;
  late GoogleMapController _mapController;
  Marker? waypointMarker; // For storing waypoint marker

  String? userPaymentMethod;
  bool isLoadingPaymentMethod = true; // Loader while fetching payment method
  List<LatLng> waypoints = []; // Waypoints list
  double? distance; // Store calculated distance
  String? duration; // Store estimated time
  String enteredBikeCode = ''; // Store entered bike code
  bool isBikeCodeValid = false; // Track bike code validity
  Bike? bike;

  @override
  void initState() {
    super.initState();
    _controller = BicycleSelectionController(
      startPoint: widget.startPoint,
      destinationPoint: widget.destinationPoint,
      mode: 'bicycling', // Mode is set to 'bicycling'
    );

    _fetchRouteInfo(); // Fetch route and polyline on init
    _fetchPaymentMethod(); // Fetch payment method on init
  }

  // Fetch the route information and polyline
  Future<void> _fetchRouteInfo() async {
    await _controller.getRouteInfo(waypoints);
    await _controller.getPolyline();
    setState(() {
      distance = double.tryParse(_controller.totalDistance.replaceAll(' km', ''));
      duration = _controller.estimatedTime;
    });
  }

  // Fetch the user's payment method from Firestore
  Future<void> _fetchPaymentMethod() async {
    PaymentMethodController paymentController = PaymentMethodController();
    String? paymentMethod = await paymentController.fetchPaymentMethod();

    setState(() {
      userPaymentMethod = paymentMethod;
      isLoadingPaymentMethod = false;
    });
  }

  // Check if the bike code exists in Firebase Firestore
  Future<void> _checkBikeCode(String bikeCode) async {
  final firestoreInstance = FirebaseFirestore.instance;
  final doc = await firestoreInstance
      .collection('bikes')
      .where('number', isEqualTo: bikeCode)
      .get();

  if (doc.docs.isNotEmpty) {
    final bikeData = doc.docs.first.data();
    // Add document ID to bike data for tracking and status update
    bikeData['id'] = doc.docs.first.id;
    Bike foundBike = Bike.fromJson(bikeData);

    setState(() {
      isBikeCodeValid = true;
      bike = foundBike;
    });
  } else {
    setState(() {
      isBikeCodeValid = false;
      bike = null;
    });
  }
}


  // Get the correct image based on the payment method
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

  // Handle the logic for starting a ride
  Future<void> _handleStartRide() async {
    if (userPaymentMethod == 'none' || userPaymentMethod == null) {
      // Navigate to the payment selection page if no valid payment method
      final selectedPaymentMethod = await Navigator.pushNamed(context, '/paymentApp');
      if (selectedPaymentMethod != null) {
        setState(() {
          userPaymentMethod = selectedPaymentMethod.toString();
          _fetchPaymentMethod(); // Reload the payment method
        });
      }
      return;
    }

    if (!isBikeCodeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid bike code. Please enter a valid bike code.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Start the ride
    if (bike != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Ride(
            startPoint: widget.startPoint,
            destinationPoint: widget.destinationPoint,
            destinationName: widget.destinationName,
            waypoints: waypoints,
            bike: bike!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No bike selected. Please enter a valid bike code.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Handle map tap to add a waypoint and recalculate route
  void _onMapTap(LatLng position) {
    setState(() {
      waypoints.clear(); // Clear previous waypoints
      waypoints.add(position); // Add the new waypoint

      waypointMarker = Marker(
        markerId: MarkerId('waypoint'), // Use 'waypoint' as the marker ID
        position: position,
        infoWindow: InfoWindow(title: 'Waypoint'),
      );
    });

    // Recalculate the polyline with waypoints
    _controller.getPolylineWithWaypoints(waypoints).then((_) async {
      await _controller.getRouteInfo(waypoints); // Update route info
      setState(() {
        distance = double.tryParse(_controller.totalDistance.replaceAll(' km', ''));
        duration = _controller.estimatedTime;
      });
    });
  }

  // Check if both bike code is valid and payment method is available
  bool _isStartButtonEnabled() {
    return isBikeCodeValid && userPaymentMethod != null && userPaymentMethod != 'none';
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

                // Row to align the text and info button at the same level
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns elements to the ends
                  children: [
                    Text("Choose your bike", style: TextStyle(fontSize: 18)),
                    Tooltip(
                      message: 'Price: 1 CHF per minute, minimum charge 5 CHF',
                      child: IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () {
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
                TextField(
                  decoration: InputDecoration(
                    labelText: "Enter the bike code or take a photo of the QR code",
                    suffixIcon: Icon(Icons.camera_alt),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      enteredBikeCode = value;
                    });
                    _checkBikeCode(enteredBikeCode); // Validate bike code on change
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Button(
                      text: "Cancel",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      isFilled: true,
                      color: Colors.red,
                      horizontalPadding: 20.0,
                      verticalPadding: 16.0,
                    ),
                    SizedBox(width: 10),
                    Button(
                      text: "Start Ride",
                      onPressed: () {
                        _handleStartRide();
                      },
                      isFilled: _isStartButtonEnabled(), 
                      color: _isStartButtonEnabled() ? Theme.of(context).primaryColor : Colors.grey, // Grey out when disabled
                      horizontalPadding: 20.0,
                      verticalPadding: 12.0,
                      image: _getPaymentImage(),
                      icon: userPaymentMethod == 'none' ? Icons.warning : null,
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
