import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/repository/bike_repository.dart';
import 'package:valais_roll/data/repository/station_repository.dart';

class OwnerBikesController extends ChangeNotifier {
  final BikeRepository _bikeRepository = BikeRepository();
  final StationRepository _stationRepository = StationRepository();
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
    _stations = await _stationRepository.getAllStations();
    notifyListeners();
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
      return _bikes.where((bike) => bike.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
  }

  Future<void> addBike(Bike bike) async {
    try {
      await _bikeRepository.addBike(bike);
      _bikes.add(bike);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding bike: $e');
    }
  }

  Future<void> updateBike(Bike bike) async {
    try {
      await _bikeRepository.updateBike(bike);
      await _fetchBikes(); // Refresh the list of bikes after update
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating bike: $e');
    }
  }

  Future<void> deleteBike(Bike bike) async {
    try {
      await _bikeRepository.deleteBike(bike);
      _bikes.removeWhere((b) => b.id == bike.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting bike: $e');
    }
  }
}