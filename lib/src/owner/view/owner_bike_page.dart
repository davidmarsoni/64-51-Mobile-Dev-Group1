import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valais_roll/src/owner/controller/owner_bikes_controller.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/enums/BikeState.dart';
import 'package:valais_roll/src/owner/widgets/base_page.dart';

class OwnerBikePage extends StatelessWidget {
  const OwnerBikePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OwnerBikesController(),
      child: BasePage(
        body: Scaffold(
          appBar: AppBar(
            title: Text('Bikes'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    Provider.of<OwnerBikesController>(context, listen: false).updateSearchQuery(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<BikeState>(
                  hint: Text('Select Status'),
                  items: BikeState.values.map((BikeState value) {
                    return DropdownMenuItem<BikeState>(
                      value: value,
                      child: Text(value.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      Provider.of<OwnerBikesController>(context, listen: false).filterByStatus(value);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _BikeForm(),
              ),
              Expanded(
                child: Consumer<OwnerBikesController>(
                  builder: (context, controller, child) {
                    return ListView.builder(
                      itemCount: controller.filteredBikes.length,
                      itemBuilder: (context, index) {
                        final bike = controller.filteredBikes[index];
                        return ListTile(
                          title: Text(bike.model),
                          subtitle: Text('Station: ${bike.stationReference}, Status: ${bike.bike_state.toString().split('.').last}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              Provider.of<OwnerBikesController>(context, listen: false).deleteBike(bike);
                            },
                          ),
                        );
                      },
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
}

class _BikeForm extends StatefulWidget {
  @override
  __BikeFormState createState() => __BikeFormState();
}

class __BikeFormState extends State<_BikeForm> {
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _numberController = TextEditingController();
  BikeState? _selectedStatus;
  final _stationReferenceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _modelController,
          decoration: InputDecoration(labelText: 'Model'),
        ),
        TextField(
          controller: _numberController,
          decoration: InputDecoration(labelText: 'Number'),
        ),
        DropdownButton<BikeState>(
          hint: Text('Select Status'),
          value: _selectedStatus,
          items: BikeState.values.map((BikeState value) {
            return DropdownMenuItem<BikeState>(
              value: value,
              child: Text(value.toString().split('.').last),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStatus = value;
            });
          },
        ),
        TextField(
          controller: _stationReferenceController,
          decoration: InputDecoration(labelText: 'Station Reference'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _modelController.text.isNotEmpty &&
                _numberController.text.isNotEmpty &&
                _selectedStatus != null &&
                _stationReferenceController.text.isNotEmpty) {
              final newBike = Bike(
                name: _nameController.text,
                model: _modelController.text,
                number: _numberController.text,
                bike_state: _selectedStatus!,
                stationReference: _stationReferenceController.text,
              );
              Provider.of<OwnerBikesController>(context, listen: false).addBike(newBike);
              _nameController.clear();
              _modelController.clear();
              _numberController.clear();
              _stationReferenceController.clear();
              setState(() {
                _selectedStatus = null;
              });
            } else {
              // Show an error message if any field is empty or status is not selected
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill all fields and select a status')),
              );
            }
          },
          child: Text('Add Bike'),
        ),
      ],
    );
  }
}