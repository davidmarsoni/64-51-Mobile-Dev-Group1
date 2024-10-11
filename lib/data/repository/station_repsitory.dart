import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/Station.dart';

class StationRepository {
  final CollectionReference _stationsCollection = FirebaseFirestore.instance.collection('stations');

  // Add a new station
  Future<String> addStation(Station station, BuildContext context) async {
    try {
      await _stationsCollection.add(station.toJson());
      return 'Station added successfully';
    } catch (e) {
      _showSnackBar(context, 'Error adding station: $e');
      return 'Error adding station: $e';
    }
  }

  // Update an existing station
  Future<String> updateStation(String id, Station station, BuildContext context) async {
    try {
      await _stationsCollection.doc(id).update(station.toJson());
      return 'Station updated successfully';
    } catch (e) {
      _showSnackBar(context, 'Error updating station: $e');
      return 'Error updating station: $e';
    }
  }

  // Delete a station
  Future<String> deleteStation(String id, BuildContext context) async {
    try {
      await _stationsCollection.doc(id).delete();
      return 'Station deleted successfully';
    } catch (e) {
      _showSnackBar(context, 'Error deleting station: $e');
      return 'Error deleting station: $e';
    }
  }

  // Get a station by ID
  Future<Station?> getStationById(String id, BuildContext context) async {
    try {
      DocumentSnapshot doc = await _stationsCollection.doc(id).get();
      if (doc.exists) {
        return Station.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      _showSnackBar(context, 'Error getting station: $e');
    }
    return null;
  }

  // Get all stations
  Future<List<Station>> getAllStations(BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await _stationsCollection.get();
      return querySnapshot.docs.map((doc) => Station.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      _showSnackBar(context, 'Error getting stations: $e');
      return [];
    }
  }

  // Helper method to show SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}