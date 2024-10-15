import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/repository/bike_repository.dart';


class OwnerBikesController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BikeRepository _bikeRepository = BikeRepository();
  List<Bike> _bikes = [];
  List<Station> _stations = [];
  Bike? _selectedBike;
  String _searchQuery = '';

  List<Bike> get bikes => _bikes;
  List<Station> get stations => _stations;
  Bike? get selectedBike => _selectedBike;
  String get searchQuery => _searchQuery;

  OwnerBikesController() {
    _fetchBikes();
    _fetchStations();
  }

  Future<void> _fetchBikes() async {
    _bikes = await _bikeRepository.getAllBikes();
   
    notifyListeners();
  }

  Future<void> _fetchStations() async {
   
  }

  void selectBike(Bike bike) {
    _selectedBike = bike;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Bike> get filteredBikes {
    if (_searchQuery.isEmpty) {
      return _bikes;
    } else {
      return _bikes.where((bike) => bike.model.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
  }

  Future<void> addBike(Bike bike) async {
    final docRef = await _firestore.collection('bikes').add(bike.toJson());
    bike.id = docRef.id; // Assign the generated ID to the bike
    _bikes.add(bike);
    notifyListeners();
  }

  Future<void> updateBike(Bike bike) async {
    try {
      if (bike.id == null) {
        throw Exception('Bike ID is null');
      }
      await _bikeRepository.updateBike(bike.id!, bike);
      await _fetchBikes(); // Refresh the list of bikes after update
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating bike: $e');
    }
  }

  Future<void> deleteBike(Bike bike) async {
    try {
      if (bike.id == null) {
        throw Exception('Bike ID is null');
      }
      await _bikeRepository.deleteBike(bike.id!);
      await _fetchBikes(); // Refresh the list of bikes after deletion
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting bike: $e');
    }
  }
}