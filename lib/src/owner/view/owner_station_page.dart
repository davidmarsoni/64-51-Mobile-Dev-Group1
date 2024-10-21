import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/data/repository/bike_repository.dart';
import 'package:valais_roll/data/repository/station_repository.dart';
import 'package:valais_roll/src/owner/controller/owner_stations_controller.dart';
import 'package:valais_roll/src/owner/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';

class OwnerStationPage extends StatefulWidget {
  @override
  _OwnerStationPageState createState() => _OwnerStationPageState();
}

class _OwnerStationPageState extends State<OwnerStationPage> {
  bool isViewMode = false;
  bool isEditMode = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _searchController = TextEditingController();

  List<Bike> _bikes = []; // State variable to store the list of bikes
  List<Bike> _bikesWithNoStation = []; // State variable to store the list of bikes with no station
  List<Bike> _selectedBikes = []; // State variable to store the selected bikes
  final BikeRepository _bikeRepository = BikeRepository(); // Instance of BikeRepository
  final StationRepository _stationRepository = StationRepository(); // Instance of StationRepository

  @override
  void initState() {
    super.initState();
    _fetchBikes(); // Fetch bikes when the widget is initialized
  }

  Future<void> _fetchBikes() async {
    try {
      final bikesList = await _bikeRepository.getAllBikes();
      final bikesListWithNoStation = await _bikeRepository.getBikesWithNoStation();
      setState(() {
        _bikes = bikesList;
        _bikesWithNoStation = bikesListWithNoStation;
      });
    } catch (e) {
      debugPrint('Error fetching bikes: $e');
    }
  }

  Future<int> _getAvailableBikesCount(String stationId) async {
    try {
      return await _stationRepository.countAvailableBikes(stationId);
    } catch (e) {
      debugPrint('Error fetching available bikes count: $e');
      return 0;
    }
  }

  void _addBike(Bike bike) {
    if (!_selectedBikes.contains(bike)) {
      setState(() {
        _selectedBikes.add(bike);
      });
    }
  }

  void _removeBike(Bike bike) {
    setState(() {
      _selectedBikes.remove(bike);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OwnerStationsController(),
      builder: (context, child) {
        return BasePage(
          body: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Stations'),
                  Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isViewMode = false;
                        isEditMode = false;
                        _clearFormFields();
                      });
                    },
                    child: Text('Add Station'),
                  ),
                ],
              ),
            ),
            body: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  Provider.of<OwnerStationsController>(context, listen: false).updateSearchQuery(value);
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Button(
                              onPressed: () {
                                Provider.of<OwnerStationsController>(context, listen: false).updateSearchQuery(_searchController.text);
                              },
                              text: 'Search',
                              horizontalPadding: 15,
                              verticalPadding: 22,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Consumer<OwnerStationsController>(
                          builder: (context, controller, child) {
                            return ListView.builder(
                              itemCount: controller.filteredStations.length,
                              itemBuilder: (context, index) {
                                final station = controller.filteredStations[index];
                                return FutureBuilder<int>(
                                  future: _getAvailableBikesCount(station.id!),
                                  builder: (context, snapshot) {
                                    final availableBikesCount = snapshot.data ?? 0;
                                    return ListTile(
                                      title: Text(station.name ?? 'Unknown Name'),
                                      subtitle: Text('Available Bikes: $availableBikesCount'),
                                      trailing: IconButton(
                                        icon: Icon(Icons.arrow_forward),
                                        onPressed: () {
                                          setState(() {
                                            isViewMode = true;
                                            isEditMode = false;
                                            _populateFormFields(station);
                                          });
                                          controller.selectStation(station);
                                        },
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isViewMode = true;
                                          isEditMode = false;
                                          _populateFormFields(station);
                                        });
                                        controller.selectStation(station);
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Consumer<OwnerStationsController>(
                    builder: (context, controller, child) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAddStationForm(context, controller),
                              SizedBox(height: 20),
                              if (isViewMode) _buildEditDeleteButtons(context, controller),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _populateFormFields(Station station) {
    _nameController.text = station.name ?? '';
    _addressController.text = station.address ?? '';
    _latitudeController.text = station.coordinates?.latitude.toString() ?? '';
    _longitudeController.text = station.coordinates?.longitude.toString() ?? '';
    _selectedBikes = _bikes.where((bike) => station.bikeReferences.contains(bike.id)).toList();
  }

  void _clearFormFields() {
    _nameController.clear();
    _addressController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _selectedBikes.clear();
  }

  String _getFormTitle() {
    if (isViewMode) {
      return isEditMode ? 'Edit Station' : 'View Station';
    }
    return 'Add New Station';
  }

  Widget _buildAddStationForm(BuildContext context, OwnerStationsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(_getFormTitle(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            enabled: !isViewMode || isEditMode,
            style: TextStyle(color: isViewMode ? Colors.black : null),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
            enabled: !isViewMode || isEditMode,
            style: TextStyle(color: isViewMode ? Colors.black : null),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an address';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: _latitudeController,
            decoration: InputDecoration(
              labelText: 'Latitude',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            enabled: !isViewMode || isEditMode,
            style: TextStyle(color: isViewMode ? Colors.black : null),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a latitude';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: _longitudeController,
            decoration: InputDecoration(
              labelText: 'Longitude',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            enabled: !isViewMode || isEditMode,
            style: TextStyle(color: isViewMode ? Colors.black : null),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a longitude';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ),
        if (!isViewMode || isEditMode)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: DropdownButtonFormField<Bike>(
              decoration: InputDecoration(
                labelText: 'Select a Bike',
                border: OutlineInputBorder(),
              ),
              items: _bikesWithNoStation.map((Bike bike) {
                return DropdownMenuItem<Bike>(
                  value: bike,
                  child: Text(bike.name),
                  enabled: !_selectedBikes.contains(bike),
                );
              }).toList(),
              onChanged: (Bike? newValue) {
                if (newValue != null && !_selectedBikes.contains(newValue)) {
                  _addBike(newValue);
                }
              },
              validator: (value) {
                // Add any necessary validation here
                return null;
              },
            ),
          ),
        SizedBox(height: 10),
        if (_selectedBikes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Selected Bikes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        Wrap(
          spacing: 8.0,
          children: _selectedBikes.map((bike) {
            return Chip(
              label: Text(bike.name),
              onDeleted: (!isViewMode || isEditMode) ? () {
                _removeBike(bike);
              } : null,
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        if (!isViewMode)
          OutlinedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final name = _nameController.text;
                final address = _addressController.text;
                final bikeReferences = _selectedBikes.map((bike) => bike.id).toList();
                final latitude = double.tryParse(_latitudeController.text);
                final longitude = double.tryParse(_longitudeController.text);

                if (latitude != null && longitude != null) {
                  final newStation = Station(
                    name: name,
                    address: address,
                    bikeReferences: bikeReferences.whereType<String>().toList(),
                    coordinates: GeoPoint(latitude, longitude),
                  );

                  controller.addStation(newStation).then((result) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Station added successfully')));
                    _clearFormFields();
                    _fetchBikes(); // Refresh the list of available bikes
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid coordinates')));
                }
              }
            },
            child: Text('Add Station'),
          ),
      ],
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, OwnerStationsController controller) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this station?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                final station = controller.selectedStation!;
                await controller.deleteStation(station);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Station deleted successfully')));
                setState(() {
                  isViewMode = false;
                  _clearFormFields(); // Clear form fields after deletion
                });
                Navigator.of(context).pop(); // Dismiss the dialog
                _fetchBikes(); // Refresh the list of available bikes
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditDeleteButtons(BuildContext context, OwnerStationsController controller) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {
            if (isEditMode) {
              if (_formKey.currentState!.validate()) {
                final updatedStation = Station(
                  id: controller.selectedStation!.id,
                  name: _nameController.text,
                  address: _addressController.text,
                  bikeReferences: _selectedBikes.map((bike) => bike.id).whereType<String>().toList(),
                  coordinates: GeoPoint(
                    double.tryParse(_latitudeController.text) ?? 0.0,
                    double.tryParse(_longitudeController.text) ?? 0.0,
                  ),
                );

                controller.updateStation(updatedStation).then((result) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Station updated successfully')));
                  setState(() {
                    isViewMode = true;
                    isEditMode = false;
                  });
                  _fetchBikes(); // Refresh the list of available bikes
                });
              }
            } else {
              setState(() {
                isEditMode = true;
              });
            }
          },
          child: Text(isEditMode ? 'Save' : 'Edit'),
        ),
        SizedBox(width: 10),
        OutlinedButton(
          onPressed: isEditMode
              ? null
              : () {
                  _showDeleteConfirmationDialog(context, controller);
                },
          child: Text('Delete'),
        ),
      ],
    );
  }
}