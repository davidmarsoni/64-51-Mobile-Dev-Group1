import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/repository/bike_repository.dart';
import 'package:valais_roll/data/repository_manager.dart/trip_repository_manager.dart';
import 'package:valais_roll/src/user/new_ride/controller/bicycle_selection_controller.dart';
import 'package:valais_roll/src/user/new_ride/view/ride.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';
import 'package:valais_roll/src/user/payment/controller/payment_method_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore import

class BicycleSelectionView extends StatefulWidget {
  final LatLng startPoint;
  final String startStationId;
  final LatLng destinationPoint;
  final String destinationStationId;
  final String destinationName;

  const BicycleSelectionView(
      {super.key, 
      required this.startPoint, 
      required this.startStationId,
      required this.destinationPoint, 
      required this.destinationStationId,
      required this.destinationName});

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
  List<String> _availableBikeCodes = [];

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
    _loadAvailableBikes(); // Add this line
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

  Future<void> _checkBikeCode(String bikeCode) async {
    BikeRepository bikeRepository = BikeRepository();
    List<Bike> availableBikes = await bikeRepository.getAvailableBikesForStation(widget.startStationId);
  
    try {
      Bike foundBike = availableBikes.firstWhere((bike) => bike.number == bikeCode);
      setState(() {
        isBikeCodeValid = true;
        bike = foundBike;
      });
    } catch (e) {
      setState(() {
        isBikeCodeValid = false;
        bike = null;
      });
    }
  }

  // Add this method to load available bikes:
  Future<void> _loadAvailableBikes() async {
    BikeRepository bikeRepository = BikeRepository();
    List<Bike> bikes = await bikeRepository.getAvailableBikesForStation(widget.startStationId);
    setState(() {
      _availableBikeCodes = bikes.map((bike) => bike.number).toList();
    });
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

    //verify the bike code
    if (!isBikeCodeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid bike code. Please enter a valid bike code.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    TripRepositoryManager tripRepositoryManager = TripRepositoryManager();

    //start the bicycle trip

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userRef = currentUser.uid;
      String bikeRef = bike!.id!;
      tripRepositoryManager.startTrip(userRef, bikeRef, widget.startStationId).then((_) {
        //add the interest point if it exists to the trip
        if (waypoints.isNotEmpty) {
          tripRepositoryManager.addInterestPoint(
            currentUser!.uid,
            GeoPoint(waypoints.first.latitude, waypoints.first.longitude),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting trip: $error'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not logged in. Please log in to start a trip.'),
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
            startStationId: widget.startStationId,
            destinationPoint: widget.destinationPoint,
            destinationStationId: widget.destinationStationId,
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
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return _availableBikeCodes.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    setState(() {
                      enteredBikeCode = selection;
                    });
                    _checkBikeCode(selection);
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: "Enter the bike code or take a photo of the QR code",
                        suffixIcon: Icon(Icons.camera_alt),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          enteredBikeCode = value;
                        });
                        _checkBikeCode(value);
                      },
                    );
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
                  markerId: MarkerId(widget.startStationId),
                  position: widget.startPoint,
                  infoWindow: InfoWindow(title: 'Start Point'),
                ),
                Marker(
                  markerId: MarkerId(widget.destinationStationId),
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
