import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valais_roll/data/objects/app_user.dart';
import 'package:valais_roll/src/owner/controller/owner_user_controller.dart';
import 'package:valais_roll/src/owner/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';
import 'package:valais_roll/data/objects/history.dart';

class OwnerUserPage extends StatefulWidget {
  @override
  _OwnerUserPageState createState() => _OwnerUserPageState();
}

class _OwnerUserPageState extends State<OwnerUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _npaController = TextEditingController();
  final _localityController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _usernameController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OwnerUserController(),
      builder: (context, child) {
        return BasePage(
          body: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Users'),
                  Spacer(),
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
                                  Provider.of<OwnerUserController>(context, listen: false).updateSearchQuery(value);
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Button(
                              onPressed: () {
                                Provider.of<OwnerUserController>(context, listen: false).updateSearchQuery(_searchController.text);
                              },
                              text: 'Search',
                              horizontalPadding: 15,
                              verticalPadding: 22,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Consumer<OwnerUserController>(
                          builder: (context, controller, child) {
                            return ListView.builder(
                              itemCount: controller.users.length,
                              itemBuilder: (context, index) {
                                final user = controller.users[index];
                                return ListTile(
                                  title: Text('${user.name} ${user.surname}'),
                                  subtitle: Text('Email: ${user.email}'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      _populateFormFields(user);
                                      controller.selectUser(user);
                                      controller.fetchUserHistory(user.uid!);
                                    },
                                  ),
                                  onTap: () {
                                    _populateFormFields(user);
                                    controller.selectUser(user);
                                    controller.fetchUserHistory(user.uid!);
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
                  child: Consumer<OwnerUserController>(
                    builder: (context, controller, child) {
                      if (controller.selectedUser == null) {
                        return Center(child: Text('Select a user to view details'));
                      }
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Align(
                            alignment: Alignment.topLeft, // Align content to the top
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildUserInfoForm(),
                                SizedBox(height: 20),
                                Text('User History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                if (controller.userHistory.isEmpty)
                                  Text('No history available')
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: controller.userHistory.length,
                                    itemBuilder: (context, index) {
                                      final historyItem = controller.userHistory[index];
                                      return ListTile(
                                        title: Text('Ride from ${historyItem.startStationName ?? historyItem.startStationRef} to ${historyItem.endStationName ?? historyItem.endStationRef ?? 'In Progress'}'),
                                        subtitle: Text('Bike: ${historyItem.bikeName ?? historyItem.bikeRef}\nStarted at: ${historyItem.startTime}'),
                                        onTap: () {
                                          _showHistoryDetails(context, historyItem);
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
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

  void _populateFormFields(AppUser user) {
    _nameController.text = user.name;
    _surnameController.text = user.surname;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _addressController.text = user.address;
    _numberController.text = user.number;
    _npaController.text = user.npa;
    _localityController.text = user.locality;
    _birthDateController.text = user.birthDate;
    _usernameController.text = user.username;
  }

  Widget _buildUserInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        _buildTextFormField(_nameController, 'Name'),
        _buildTextFormField(_surnameController, 'Surname'),
        _buildTextFormField(_emailController, 'Email'),
        _buildTextFormField(_phoneController, 'Phone'),
        _buildTextFormField(_addressController, 'Address'),
        _buildTextFormField(_numberController, 'Number'),
        _buildTextFormField(_npaController, 'NPA'),
        _buildTextFormField(_localityController, 'Locality'),
        _buildTextFormField(_birthDateController, 'Birth Date'),
        _buildTextFormField(_usernameController, 'Username'),
      ],
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        enabled: false,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  void _showHistoryDetails(BuildContext context, History history) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Ride Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Start Station: ${history.startStationName ?? history.startStationRef}'),
                  Text('End Station: ${history.endStationName ?? history.endStationRef ?? 'In Progress'}'),
                  Text('Bike: ${history.bikeName ?? history.bikeRef}'),
                  Text('Start Time: ${history.startTime}'),
                  if (history.endTime != null) Text('End Time: ${history.endTime}'),
                  SizedBox(height: 10),
                  Text('Interest Points:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView(
                      children: history.interestPoints.map((point) => ListTile(
                        title: Text('Lat: ${point.latitude}, Lng: ${point.longitude}'),
                      )).toList(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(history.startStationCoordinates!.latitude, history.startStationCoordinates!.longitude),
                        zoom: 14.0,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('start'),
                          position: LatLng(history.startStationCoordinates!.latitude, history.startStationCoordinates!.longitude),
                          infoWindow: InfoWindow(title: 'Start Station'),
                        ),
                        if (history.endStationCoordinates != null)
                          Marker(
                            markerId: MarkerId('end'),
                            position: LatLng(history.endStationCoordinates!.latitude, history.endStationCoordinates!.longitude),
                            infoWindow: InfoWindow(title: 'End Station'),
                          ),
                      },
                      polylines: {
                        Polyline(
                          polylineId: PolylineId('route'),
                          points: [
                            LatLng(history.startStationCoordinates!.latitude, history.startStationCoordinates!.longitude),
                            if (history.endStationCoordinates != null)
                              LatLng(history.endStationCoordinates!.latitude, history.endStationCoordinates!.longitude),
                          ],
                          color: Colors.blue,
                          width: 5,
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}