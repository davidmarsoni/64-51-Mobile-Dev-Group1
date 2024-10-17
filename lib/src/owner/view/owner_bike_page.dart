import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valais_roll/src/owner/controller/owner_bikes_controller.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/data/repository/station_repository.dart';
import 'package:valais_roll/data/enums/BikeState.dart';
import 'package:valais_roll/src/owner/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart'; // Import the Button widget

class OwnerBikePage extends StatefulWidget {
  @override
  _OwnerBikePageState createState() => _OwnerBikePageState();
}

class _OwnerBikePageState extends State<OwnerBikePage> {
  bool isViewMode = false;
  bool isEditMode = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _numberController = TextEditingController();
  BikeState? _selectedStatus;
  Station? _selectedStation;
  final _searchController = TextEditingController();

  List<Station> _stations = []; // State variable to store the list of stations
  final StationRepository _stationRepository = StationRepository(); // Instance of StationRepository

  @override
  void initState() {
    super.initState();
    _fetchStations(); // Fetch stations when the widget is initialized
  }

  Future<void> _fetchStations() async {
    final stationsList = await _stationRepository.getAllStations();
    setState(() {
      _stations = stationsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OwnerBikesController(),
      builder: (context, child) {
        return BasePage(
          body: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Bikes'),
                  Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isViewMode = false;
                        isEditMode = false;
                        _clearFormFields();
                      });
                    },
                    child: Text('Add Bike'),
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
                                  Provider.of<OwnerBikesController>(context, listen: false).updateSearchQuery(value);
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Button(
                              onPressed: () {
                                Provider.of<OwnerBikesController>(context, listen: false).updateSearchQuery(_searchController.text);
                              },
                              text: 'Search',
                              horizontalPadding: 15,
                              verticalPadding: 22,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Consumer<OwnerBikesController>(
                          builder: (context, controller, child) {
                            return ListView.builder(
                              itemCount: controller.filteredBikes.length,
                              itemBuilder: (context, index) {
                                final bike = controller.filteredBikes[index];
                                return ListTile(
                                  title: Text(bike.name),
                                  subtitle: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getColorForBikeState(bike.bike_state),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      bike.bike_state.toString().split('.').last,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      setState(() {
                                        isViewMode = true;
                                        isEditMode = false;
                                        _populateFormFields(bike);
                                      });
                                      controller.selectBike(bike);
                                    },
                                  ),
                                  onTap: () {
                                    setState(() {
                                      isViewMode = true;
                                      isEditMode = false;
                                      _populateFormFields(bike);
                                    });
                                    controller.selectBike(bike);
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
                  child: Consumer<OwnerBikesController>(
                    builder: (context, controller, child) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAddBikeForm(context, controller),
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

  void _populateFormFields(Bike bike) {
    _nameController.text = bike.name;
    _modelController.text = bike.model;
    _numberController.text = bike.number;
    _selectedStatus = bike.bike_state;
    _selectedStation = _stations.firstWhere((station) => station.id == bike.stationReference, orElse: () => _stations.first);
  }

  void _clearFormFields() {
    _nameController.clear();
    _modelController.clear();
    _numberController.clear();
    _selectedStatus = null;
    _selectedStation = null;
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(),
    );
  }

  Widget _buildAddBikeForm(BuildContext context, OwnerBikesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            isViewMode ? 'Information about the bike' : 'Add New Bike',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Name'),
            enabled: !isViewMode || isEditMode,
            style: TextStyle(color: isViewMode && !isEditMode ? Colors.black : null),
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
            controller: _modelController,
            decoration: _inputDecoration('Model'),
            enabled: !isViewMode || isEditMode,
            style: TextStyle(color: isViewMode && !isEditMode ? Colors.black : null),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a model';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: _numberController,
            decoration: _inputDecoration('Number'),
            enabled: !isViewMode || isEditMode,
            style: TextStyle(color: isViewMode && !isEditMode ? Colors.black : null),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a number';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<BikeState>(
            hint: Text('Select Status'),
            value: _selectedStatus,
            items: BikeState.values.map((BikeState value) {
              return DropdownMenuItem<BikeState>(
                value: value,
                child: Text(value.toString().split('.').last),
              );
            }).toList(),
            onChanged: !isViewMode || isEditMode ? (value) {
              setState(() {
                _selectedStatus = value;
              });
            } : null,
            decoration: _inputDecoration('Status'),
            validator: (value) {
              if (value == null) {
                return 'Please select a status';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<Station>(
            hint: Text('Select Station'),
            value: _selectedStation,
            items: _stations.map((Station station) {
              return DropdownMenuItem<Station>(
                value: station,
                child: Text(station.name ?? 'Unknown Station'),
              );
            }).toList(),
            onChanged: !isViewMode || isEditMode ? (value) {
              setState(() {
                _selectedStation = value;
              });
            } : null,
            decoration: _inputDecoration('Station'),
            validator: (value) {
              if (value == null) {
                return 'Please select a station';
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
                final newBike = Bike(
                  name: _nameController.text,
                  model: _modelController.text,
                  number: _numberController.text,
                  bike_state: _selectedStatus!,
                  stationReference: _selectedStation?.id ?? '',
                );

                controller.addBike(newBike).then((result) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bike added successfully')));
                  _clearFormFields();
                });
              }
            },
            child: Text('Add Bike'),
          ),
      ],
    );
  }

  Widget _buildEditDeleteButtons(BuildContext context, OwnerBikesController controller) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {
            if (isEditMode) {
              if (_formKey.currentState!.validate()) {
                final updatedBike = Bike(
                  id: controller.selectedBike!.id,
                  name: _nameController.text,
                  model: _modelController.text,
                  number: _numberController.text,
                  bike_state: _selectedStatus!,
                  stationReference: _selectedStation?.id ?? '',
                );

                controller.updateBike(updatedBike).then((result) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bike updated successfully')));
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
        if (isEditMode)
          OutlinedButton(
            onPressed: () {
              setState(() {
                isEditMode = false;
                _populateFormFields(controller.selectedBike!);
              });
            },
            child: Text('Cancel'),
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

  void _showDeleteConfirmationDialog(BuildContext context, OwnerBikesController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this bike?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                final bike = controller.selectedBike!;
                await controller.deleteBike(bike);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bike deleted successfully')));
                setState(() {
                  isViewMode = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Color _getColorForBikeState(BikeState state) {
    switch (state) {
      case BikeState.inUse:
        return Colors.red;
      case BikeState.maintenance:
        return Colors.purple;
      case BikeState.available:
        return Colors.green;
      case BikeState.lost:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}