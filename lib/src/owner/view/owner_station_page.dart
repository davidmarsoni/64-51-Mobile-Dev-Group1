import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/src/owner/controller/owner_stations_controller.dart';
import 'package:valais_roll/src/owner/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';

class OwnerStationPage extends StatefulWidget {
  const OwnerStationPage({super.key});

  @override
  _OwnerStationPageState createState() => _OwnerStationPageState();
}

class _OwnerStationPageState extends State<OwnerStationPage> {
  bool isViewMode = false;
  bool isEditMode = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _bikeReferencesController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _searchController = TextEditingController();

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
                                return ListTile(
                                  title: Text(station.name ?? 'Unknown Name'),
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
    _bikeReferencesController.text = station.bikeReferences.join(', ');
    _latitudeController.text = station.coordinates?.latitude.toString() ?? '';
    _longitudeController.text = station.coordinates?.longitude.toString() ?? '';
  }

  void _clearFormFields() {
    _nameController.clear();
    _addressController.clear();
    _bikeReferencesController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
  }

  Widget _buildAddStationForm(BuildContext context, OwnerStationsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Add New Station', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: _bikeReferencesController,
            decoration: InputDecoration(
              labelText: 'Bike References (comma separated)',
              border: OutlineInputBorder(),
            ),
            enabled: !isViewMode || isEditMode,
            style: TextStyle(color: isViewMode ? Colors.black : null),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter bike references';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 10),
        if (!isViewMode)
          OutlinedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final name = _nameController.text;
                final address = _addressController.text;
                final bikeReferences = _bikeReferencesController.text.split(',').map((e) => e.trim()).toList();
                final latitude = double.tryParse(_latitudeController.text);
                final longitude = double.tryParse(_longitudeController.text);

                if (latitude != null && longitude != null) {
                  final newStation = Station(
                    name: name,
                    address: address,
                    bikeReferences: bikeReferences,
                    coordinates: GeoPoint(latitude, longitude),
                  );

                  controller.addStation(newStation).then((result) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Station added successfully')));
                    _clearFormFields();
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
                  bikeReferences: _bikeReferencesController.text.split(',').map((e) => e.trim()).toList(),
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
              : () async {
                  final station = controller.selectedStation!;
                  await controller.deleteStation(station);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Station deleted successfully')));
                  setState(() {
                    isViewMode = false;
                  });
                },
          child: Text('Delete'),
        ),
      ],
    );
  }
}