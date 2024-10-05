import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:valais_roll/src/new_ride/controller/itinary_controller.dart';
import 'package:valais_roll/src/new_ride/view/bicycle_selection_view.dart';
import 'package:valais_roll/src/widgets/base_page.dart';

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
  LatLng? _destinationLatLng;
  CameraPosition? _initialPosition;
  bool showButton = false;

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
    });
    _destinationController.addListener(() {
      _checkIfBothLocationsAreStations();
    });
  }

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    _itineraryController.dispose();
    super.dispose();
  }

  // Search either city or station and zoom to the location
  Future<void> _performSearch(bool isStart) async {
    String query = isStart ? _startController.text : _destinationController.text;

    if (query.isNotEmpty) {
      // Convert query to lowercase and trim spaces to match station names
      String normalizedQuery = query.toLowerCase().trim();

      // Check if the input matches a station name
      if (_itineraryController.stationNames.contains(normalizedQuery)) {
        // Find the corresponding station marker by name
        Marker? matchingMarker = _itineraryController.markers.firstWhere(
          (marker) => marker.infoWindow.title!.split('|')[0].toLowerCase().trim() == normalizedQuery,
          orElse: () => Marker(markerId: MarkerId('default')),
        );

        // Set the corresponding LatLng based on whether it's the start or destination
        setState(() {
          if (isStart) {
            _startLatLng = matchingMarker.position;
          } else {
            _destinationLatLng = matchingMarker.position;
          }
        });

        // Zoom to the location on the map
        final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: matchingMarker.position, zoom: 12.0),
        ));

        // Check if both start and destination are valid stations
        _checkIfBothLocationsAreStations();
        return; // Stop further execution as it's a valid station
      }

      // If the query is not a station, try geocoding the input as a city name
      try {
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          LatLng latLng = LatLng(locations.first.latitude, locations.first.longitude);

          // Move the map camera to the city location
          final GoogleMapController controller = await _mapController.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 12.0),
          ));

          // Set the LatLng as start or destination depending on the input
          setState(() {
            if (isStart) {
              _startLatLng = latLng; // Set start location to city coordinates
            } else {
              _destinationLatLng = latLng; // Set destination location to city coordinates
            }
          });

          // Check if both start and destination have valid LatLngs
          _checkIfBothLocationsAreStations();
        }
      } catch (e) {
        // Show error message if geocoding fails
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
                            marker.infoWindow.title!.split('|')[0],  // Station name
                            marker.position,  // Station coordinates
                          ),
                        );
                      }),
                    ),
                    polylines: Set<Polyline>.of(_itineraryController.polylines.values),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    mapType: MapType.normal, // Ensure mapType is set
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
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              _performSearch(true);  // Trigger search for start
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
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              _performSearch(false);  // Trigger search for destination
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
                onPressed: () {
                  if (_startLatLng != null && _destinationLatLng != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BicycleSelectionView(
                          startPoint: _startLatLng!,
                          destinationPoint: _destinationLatLng!,
                        ),
                      ),
                    );
                  } else {
                    _showErrorMessage("Both start and destination must be valid stations.");
                  }
                },
                icon: Icon(Icons.directions),
                label: Text('Validate your itinerary'),
              ),
            ),
        ],
      ),
    );
  }

  // Check if both the start and destination are valid stations and show the button
  void _checkIfBothLocationsAreStations() {
    setState(() {
      // Ensure both the input and station names are lowercased and trimmed
      String startInput = _startController.text.toLowerCase().trim();
      String destinationInput = _destinationController.text.toLowerCase().trim();

      bool startIsValid = _itineraryController.stationNames.contains(startInput);
      bool destinationIsValid = _itineraryController.stationNames.contains(destinationInput);

      // If start or destination is valid, update their respective LatLngs
      if (startIsValid) {
        Marker? matchingStartMarker = _itineraryController.markers.firstWhere(
          (marker) => marker.infoWindow.title!.split('|')[0].toLowerCase().trim() == startInput,
          orElse: () => Marker(markerId: MarkerId('default')),
        );
        _startLatLng = matchingStartMarker.position;
      }

      if (destinationIsValid) {
        Marker? matchingDestinationMarker = _itineraryController.markers.firstWhere(
          (marker) => marker.infoWindow.title!.split('|')[0].toLowerCase().trim() == destinationInput,
          orElse: () => Marker(markerId: MarkerId('default')),
        );
        _destinationLatLng = matchingDestinationMarker.position;
      }

      // Show button only if both fields contain valid station names and coordinates
      showButton = startIsValid && destinationIsValid && _startLatLng != null && _destinationLatLng != null;
    });
  }

  // Show error messages
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ));
  }

  // Handle when a station marker is tapped
  void _onStationMarkerTapped(String stationName, LatLng stationPosition) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Select as Start Station'),
              subtitle: Text('Station: $stationName'),
              onTap: () {
                setState(() {
                  _startLatLng = stationPosition;
                  _startController.text = stationName;
                  Navigator.pop(context);
                });
                _checkIfBothLocationsAreStations();  // Check after selecting the station
              },
            ),
            ListTile(
              title: Text('Select as Destination Station'),
              subtitle: Text('Station: $stationName'),
              onTap: () {
                setState(() {
                  _destinationLatLng = stationPosition;
                  _destinationController.text = stationName;
                  Navigator.pop(context);
                });
                _checkIfBothLocationsAreStations();  // Check after selecting the station
              },
            ),
          ],
        );
      },
    );
  }
}