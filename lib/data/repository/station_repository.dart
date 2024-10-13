import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:valais_roll/data/objects/Station.dart';

class StationRepository {
  final CollectionReference _stationsCollection = FirebaseFirestore.instance.collection('stations');

  Future<List<Station>> getAllStations() async {
    try {
      QuerySnapshot querySnapshot = await _stationsCollection.get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        debugPrint('Fetched station data: $data'); // Debugging statement
        return Station.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching stations: $e');
      return [];
    }
  }

  Future<String> addStation(Station station) async {
    try {
      await _stationsCollection.add(station.toJson());
      return 'Station added successfully';
    } catch (e) {
      return 'Error adding station: $e';
    }
  }

  Future<String> updateStation(String id, Station station) async {
    try {
      await _stationsCollection.doc(id).update(station.toJson());
      return 'Station updated successfully';
    } catch (e) {
      return 'Error updating station: $e';
    }
  }

  Future<String> deleteStation(String id) async {
    try {
      await _stationsCollection.doc(id).delete();
      return 'Station deleted successfully';
    } catch (e) {
      return 'Error deleting station: $e';
    }
  }

  Future<Station?> getStationById(String id) async {
    try {
      DocumentSnapshot doc = await _stationsCollection.doc(id).get();
      if (doc.exists) {
        return Station.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching station by ID: $e');
    }
    return null;
  }
}