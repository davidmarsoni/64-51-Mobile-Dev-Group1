import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:valais_roll/src/user/new_ride/controller/itinary_controller.dart';
import 'package:valais_roll/src/user/new_ride/view/bicycle_selection_page.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();
  final ItineraryController _itineraryController = ItineraryController();

  LatLng? _startLatLng;
  String _startStationId = '';
  LatLng? _destinationLatLng;
  String _destinationStationId = '';
  CameraPosition? _initialPosition;
  bool showButton = false;
  bool _isStartValid = false;
  bool _isDestinationValid = false;

  // Variables to track approved station for start and destination
  String? _approvedStartStation;
  String? _approvedDestinationStation;

  @override
  void initState() {
    super.initState();
    _itineraryController.getUserLocation();
    _itineraryController.fetchStations();

    _itineraryController.locationStream.listen((currentLocation) {
      if (currentLocation != null) {
        setState(() {
          _initialPosition = CameraPosition(
            target: currentLocation,
            zoom: 14.0,
          );
        });
      }
    });

    _itineraryController.markersStream.listen((markers) {
      setState(() {
        // Update markers on the map
      });
    });

    // Listeners for text field changes to check for valid stations
    _startController.addListener(() {
      _checkIfBothLocationsAreStations();
      _resetApprovalIconIfNeeded(true);
    });
    _destinationController.addListener(() {
      _checkIfBothLocationsAreStations();
      _resetApprovalIconIfNeeded(false);
    });
  }

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    _itineraryController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(bool isStart) async {
    String query = isStart ? _startController.text : _destinationController.text;

    if (query.isNotEmpty) {
      // Normalize input by trimming and converting to lowercase
      String normalizedQuery = query.toLowerCase().trim();
      
      print("Searching for station: $normalizedQuery");

      // Check if the normalized input matches a station name
      if (_itineraryController.stationNames.contains(normalizedQuery)) {
        // Find the marker that matches the station name
        Marker? matchingMarker = _itineraryController.markers.firstWhere(
          (marker) => marker.infoWindow.title!.split('|')[0].toLowerCase().trim() == normalizedQuery,
          orElse: () => Marker(markerId: MarkerId('default')),
        );

        if (matchingMarker.markerId.value != 'default') {
          // Check the station's capacity before selecting it
          bool capacity = await _itineraryController.capacity(matchingMarker.infoWindow.title!.split('|')[0]);
          if (!capacity) {
            _showErrorMessage("This start station has no available bicycles, please choose another start station.");
            return;
          }

          setState(() {
            if (isStart) {
              _startLatLng = matchingMarker.position;
              _approvedStartStation = matchingMarker.infoWindow.title!.split('|')[0]; // Set the approved station
            } else {
              _destinationLatLng = matchingMarker.position;
              _approvedDestinationStation = matchingMarker.infoWindow.title!.split('|')[0]; // Set the approved station
            }
          });

          _checkIfBothLocationsAreStations();
          return;
        } else {
          print("No matching station found.");
        }
      } else {
        print("Station not found in the list.");
      }

      // If input is not a station name, try to geocode the input as a city or location
      try {
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          LatLng latLng = LatLng(locations.first.latitude, locations.first.longitude);

          final GoogleMapController controller = await _mapController.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 12.0),
          ));

          setState(() {
            if (isStart) {
              _startLatLng = latLng;
              _approvedStartStation = null; // Clear approval if it's not a station
            } else {
              _destinationLatLng = latLng;
              _approvedDestinationStation = null; // Clear approval if it's not a station
            }
          });

          _checkIfBothLocationsAreStations();
        }
      } catch (e) {
        _showErrorMessage("Location not found: $query");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      isBottomNavBarEnabled: true,
      body: Stack(
        children: [
          // The Map
          Positioned.fill(
            child: _initialPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                    initialCameraPosition: _initialPosition!,
                    markers: Set<Marker>.of(
                      _itineraryController.markers.map((marker) {
                        return marker.copyWith(
                          onTapParam: () => _onStationMarkerTapped(
                            marker.infoWindow.title!.split('|')[0],
                            marker.position,
                            marker.markerId.value,
                          ),
                        );
                      }),
                    ),
                    polylines:
                        Set<Polyline>.of(_itineraryController.polylines.values),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    mapType: MapType.normal,
                  ),
          ),

          // Search fields for start and destination
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startController,
                        decoration: InputDecoration(
                          labelText: 'Start',
                          filled: true,
                          fillColor: _isStartValid
                              ? Color.fromARGB(255, 154, 236, 29)
                              : Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              _performSearch(true);
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          labelText: 'Destination',
                          filled: true,
                          fillColor: _isDestinationValid
                              ? Color.fromARGB(255, 154, 236, 29)
                              : Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              _performSearch(false);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          // Floating button to proceed, shown only when valid stations are selected
          if (showButton)
            Positioned(
              bottom: 30,
              right: 30,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  if (_startLatLng != null && _destinationLatLng != null) {
                    // Check station capacity again before navigating
                    bool capacity = await _itineraryController.capacity(_startStationId);
                    if (!capacity) {
                      _showErrorMessage("This start station has no available bicycles, please choose another start station.");
                      return;
                    }
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BicycleSelectionPage(
                          startPoint: _startLatLng!,
                          startStationId: _startStationId,
                          destinationPoint: _destinationLatLng!,
                          destinationName: _approvedDestinationStation ?? '',
                          destinationStationId: _destinationStationId,
                        ),
                      ),
                    );
                  } else {
                    _showErrorMessage(
                        "Both start and destination must be valid stations.");
                  }
                },
                icon: Icon(Icons.directions),
                label: Text('Validate your itinerary'),
              ),
            ),

          // Button to recenter the map to the user's current location
          Positioned(
            bottom: 30,
            left: 16,
            child: FloatingActionButton(
              heroTag: "recenterButton",
              onPressed: () async {
                LatLng? currentLocation = await _itineraryController.getPosition();
                final GoogleMapController controller = await _mapController.future;
                controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: currentLocation, zoom: 14.0),
                ));
              },
              child: Icon(Icons.my_location),
              mini: true, // Optional to make it smaller
            ),
          ),
        ],
      ),
    );
  }

  // Handle when a station marker is tapped
  void _onStationMarkerTapped(String stationName, LatLng stationPosition, String stationId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Start your journey to this station'),
              subtitle: Text('Station: $stationName'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/itinaryStation',
                  arguments: {
                    'stationName': stationName,
                    'stationPosition': stationPosition,
                  },
                );
              },
            ),
            ListTile(
              title: Text('Select as Start Station'),
              subtitle: Text('Station: $stationName'),
              trailing: _approvedStartStation == stationName
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () async {
                bool startCapacity = await _itineraryController.capacity(stationId);   
                if (!startCapacity) {
                  Navigator.pop(context);
                  _showErrorMessage(
                      "$stationName has no available bicycles, please choose another station.");
                } else {
                  setState(() {
                    _startLatLng = stationPosition;
                    _startStationId = stationId;
                    _startController.text = stationName;
                    _approvedStartStation = stationName;
                  });
                  Navigator.pop(context);

                  // Hide the approval icon after 1 second
                  Timer(Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() {
                        _approvedStartStation = null;
                      });
                    }
                  });
                  _checkIfBothLocationsAreStations();
                }
              },
            ),
            ListTile(
              title: Text('Select as Destination Station'),
              subtitle: Text('Station: $stationName'),
              trailing: _approvedDestinationStation == stationName
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _destinationLatLng = stationPosition;
                  _destinationStationId = stationId;
                  _destinationController.text = stationName;
                  _approvedDestinationStation = stationName;
                });
                Navigator.pop(context);

                // Hide the approval icon after 1 second
                Timer(Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _approvedDestinationStation = null;
                    });
                  }
                });
                _checkIfBothLocationsAreStations();
              },
            ),
          ],
        );
      },
    );
  }

  // Check if both the start and destination are valid stations and show the button
  void _checkIfBothLocationsAreStations() {
    setState(() {
      String startInput = _startController.text.toLowerCase().trim();
      String destinationInput = _destinationController.text.toLowerCase().trim();

      bool startIsValid = _itineraryController.stationNames.contains(startInput);
      bool destinationIsValid = _itineraryController.stationNames.contains(destinationInput);

      // Update start and destination LatLngs if valid
      if (startIsValid) {
        Marker? matchingStartMarker = _itineraryController.markers.firstWhere(
          (marker) => marker.infoWindow.title!.split('|')[0].toLowerCase().trim() == startInput,
          orElse: () => Marker(markerId: MarkerId('default')),
        );
        _startLatLng = matchingStartMarker.position;
        _approvedStartStation = matchingStartMarker.infoWindow.title!.split('|')[0]; // Approve the station
      }

      if (destinationIsValid) {
        Marker? matchingDestinationMarker = _itineraryController.markers.firstWhere(
          (marker) => marker.infoWindow.title!.split('|')[0].toLowerCase().trim() == destinationInput,
          orElse: () => Marker(markerId: MarkerId('default')),
        );
        _destinationLatLng = matchingDestinationMarker.position;
        _approvedDestinationStation = matchingDestinationMarker.infoWindow.title!.split('|')[0]; // Approve the station
      }

      // Show the button only if both stations are valid and coordinates are available
      showButton = startIsValid && destinationIsValid && _startLatLng != null && _destinationLatLng != null;
      _isStartValid = startIsValid;
      _isDestinationValid = destinationIsValid;
    });
  }

  // Reset the approval icon if the text in the start or destination field is invalid
  void _resetApprovalIconIfNeeded(bool isStart) {
    String input = isStart
        ? _startController.text.toLowerCase().trim()
        : _destinationController.text.toLowerCase().trim();
    bool isValid = _itineraryController.stationNames.contains(input);

    if (!isValid) {
      setState(() {
        if (isStart) {
          _approvedStartStation = null;
        } else {
          _approvedDestinationStation = null;
        }
      });
    }
  }

  // Show error messages
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ));
  }
}
