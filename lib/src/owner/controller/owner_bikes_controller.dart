import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/repository/bike_repository.dart';
import 'package:valais_roll/data/repository/station_repository.dart';

class OwnerBikesController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    // Add the bike to the 'bikes' collection
    final docRef = await _firestore.collection('bikes').add(bike.toJson());
    bike.id = docRef.id; // Assign the generated ID to the bike
    _bikes.add(bike);
    notifyListeners();
  
    // Update the station document to include the bike reference
    if (bike.stationReference.isNotEmpty) {
      final stationRepository = StationRepository();
      await stationRepository.addBikeRef(bike.stationReference, docRef.id);
    }
  }

    Future<void> updateBike(Bike bike) async {
      try {
        if (bike.id == null) {
          throw Exception('Bike ID is null');
        }
    
        // Fetch the previous bike data to get the previous station reference
        Bike? previousBike = await _bikeRepository.getBikeById(bike.id!);
        if (previousBike == null) {
          throw Exception('Previous bike data not found');
        }
    
        final stationRepository = StationRepository();
    
        // Remove the bike reference from the previous station if it exists
        if (previousBike.stationReference.isNotEmpty) {
          await stationRepository.deleteBikeRef(previousBike.stationReference, bike.id!);
        }
    
        // Update the bike data
        await _bikeRepository.updateBike(bike.id!, bike);
    
        // Add the bike reference to the new station
        if (bike.stationReference.isNotEmpty) {
          await stationRepository.addBikeRef(bike.stationReference, bike.id!);
        }
    
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
  
      final stationRepository = StationRepository();
  
      // Remove the bike reference from the station if it exists
      if (bike.stationReference.isNotEmpty) {
        await stationRepository.deleteBikeRef(bike.stationReference, bike.id!);
      }
  
      // Delete the bike from the repository
      await _bikeRepository.deleteBike(bike.id!);
  
      // Remove the bike from the local list and notify listeners
      _bikes.removeWhere((b) => b.id == bike.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting bike: $e');
    }
  }
}