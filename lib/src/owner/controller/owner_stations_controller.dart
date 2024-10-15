import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/repository/station_repository.dart';
import 'package:valais_roll/data/repository/bike_repository.dart';

class OwnerStationsController extends ChangeNotifier {
  final StationRepository _stationRepository = StationRepository();
  final BikeRepository _bikeRepository = BikeRepository();
  List<Station> _stations = [];
  List<Bike> _bikes = [];
  Station? _selectedStation;
  String _searchQuery = '';

  List<Station> get stations => _stations;
  List<Bike> get bikes => _bikes;
  Station? get selectedStation => _selectedStation;
  String get searchQuery => _searchQuery;

  OwnerStationsController() {
    _fetchStations();
    _fetchBikes();
  }

  Future<void> _fetchStations() async {
    try {
      _stations = await _stationRepository.getAllStations();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching stations: $e');
    }
  }

  Future<void> _fetchBikes() async {
    try {
      _bikes = await _bikeRepository.getAllBikes();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching bikes: $e');
    }
  }

  void selectStation(Station station) {
    _selectedStation = station;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Station> get filteredStations {
    if (_searchQuery.isEmpty) {
      return _stations;
    } else {
      return _stations.where((station) => station.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();
    }
  }

  Future<void> addStation(Station station) async {
    try {
      await _stationRepository.addStation(station);
      await _fetchStations();
    } catch (e) {
      debugPrint('Error adding station: $e');
    }
  }

  Future<void> deleteStation(Station station) async {
    try {
      await _stationRepository.deleteStation(station.id!);
      await _fetchStations();
    } catch (e) {
      debugPrint('Error deleting station: $e');
    }
  }

  Future<void> updateStation(Station station) async {
    try {
      await _stationRepository.updateStation(station.id!, station);
      await _fetchStations();
    } catch (e) {
      debugPrint('Error updating station: $e');
    }
  }
}