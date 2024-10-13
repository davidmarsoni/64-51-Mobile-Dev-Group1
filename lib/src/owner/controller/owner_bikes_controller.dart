import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/objects/station.dart';
import 'package:valais_roll/data/enums/BikeState.dart';

class OwnerBikesController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Bike> _bikes = [];
  List<Bike> _filteredBikes = [];
  List<Station> _stations = [];
  String _searchQuery = '';

  List<Bike> get filteredBikes => _filteredBikes;
  List<Station> get stations => _stations;

  OwnerBikesController() {
    _fetchBikes();
    _fetchStations();
  }

  Future<void> _fetchBikes() async {
    final snapshot = await _firestore.collection('bikes').get();
    _bikes = snapshot.docs.map((doc) => Bike.fromJson(doc.data())).toList();
    _filteredBikes = _bikes;
    notifyListeners();
  }

  Future<void> _fetchStations() async {
    final snapshot = await _firestore.collection('stations').get();
    _stations = snapshot.docs.map((doc) => Station.fromJson(doc.data())).toList();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filteredBikes = _bikes.where((bike) => bike.model.toLowerCase().contains(query.toLowerCase())).toList();
    notifyListeners();
  }

  void filterByStatus(BikeState status) {
    _filteredBikes = _bikes.where((bike) => bike.bike_state == status).toList();
    notifyListeners();
  }

  Future<void> addBike(Bike bike) async {
    final docRef = await _firestore.collection('bikes').add(bike.toJson());
    bike.id = docRef.id; // Assign the generated ID to the bike
    _bikes.add(bike);
    _filteredBikes = _bikes;
    notifyListeners();
  }

  Future<void> deleteBike(Bike bike) async {
    await _firestore.collection('bikes').doc(bike.id).delete();
    _bikes.remove(bike);
    _filteredBikes = _bikes;
    notifyListeners();
  }
}