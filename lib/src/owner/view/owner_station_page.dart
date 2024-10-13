import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valais_roll/src/owner/controller/owner_stations_controller.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/src/owner/widgets/base_page.dart';

class OwnerStationPage extends StatelessWidget {
  const OwnerStationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OwnerStationsController(),
      child: BasePage(
        body: Scaffold(
          appBar: AppBar(
            title: Text('Stations'),
          ),
          body: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          Provider.of<OwnerStationsController>(context, listen: false).updateSearchQuery(value);
                        },
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
                                onTap: () {
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAddStationForm(context, controller),
                          SizedBox(height: 20),
                          if (controller.selectedStation != null)
                            _buildStationDetails(context, controller),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddStationForm(BuildContext context, OwnerStationsController controller) {
    final _nameController = TextEditingController();
    final _addressController = TextEditingController();
    final _bikeReferencesController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add New Station', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(labelText: 'Address'),
        ),
        TextField(
          controller: _bikeReferencesController,
          decoration: InputDecoration(labelText: 'Bike References (comma separated)'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text;
            final address = _addressController.text;
            final bikeReferences = _bikeReferencesController.text.split(',').map((e) => e.trim()).toList();

            final newStation = Station(
              name: name,
              address: address,
              bikeReferences: bikeReferences,
            );

            controller.addStation(newStation).then((result) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Station added successfully')));
              _nameController.clear();
              _addressController.clear();
              _bikeReferencesController.clear();
            });
          },
          child: Text('Add Station'),
        ),
      ],
    );
  }

  Widget _buildStationDetails(BuildContext context, OwnerStationsController controller) {
    final station = controller.selectedStation!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name: ${station.name}', style: TextStyle(fontSize: 18)),
        Text('Address: ${station.address}', style: TextStyle(fontSize: 18)),
        Text('Coordinates: ${station.coordinates?.latitude}, ${station.coordinates?.longitude}', style: TextStyle(fontSize: 18)),
        Text('Bike References: ${station.bikeReferences.join(', ')}', style: TextStyle(fontSize: 18)),
        SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // Implement edit functionality
              },
              child: Text('Edit'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                
              },
              child: Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }
}