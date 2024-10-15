import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/data/enums/BikeState.dart';
import 'package:valais_roll/data/objects/bike.dart';

class BikeRepository {
  final CollectionReference _bikesCollection = FirebaseFirestore.instance.collection('bikes');

  // Add a new bike
  Future<String> addBike(Bike bike) async {
    try {
      DocumentReference docRef = await _bikesCollection.add(bike.toJson());
      bike.id = docRef.id; // Assign the generated ID to the bike
      return 'Bike added successfully';
    } catch (e) {
      return 'Error adding bike: $e';
    }
  }

  // Update an existing bike
  Future<String> updateBike(String id, Bike bike) async {
    try {
      await _bikesCollection.doc(id).update(bike.toJson());
      return 'Bike updated successfully';
    } catch (e) {
      return 'Error updating bike: $e';
    }
  }

  // Delete a bike
  Future<String> deleteBike(String id) async {
    try {
      await _bikesCollection.doc(id).delete();
      return 'Bike deleted successfully';
    } catch (e) {
      return 'Error deleting bike: $e';
    }
  }

  // Get a bike by ID
  Future<Bike?> getBikeById(String id) async {
    try {
      DocumentSnapshot doc = await _bikesCollection.doc(id).get();
      if (doc.exists) {
        return Bike.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error getting bike: $e');
    }
    return null;
  }

  // Get all bikes, ordered by name
  Future<List<Bike>> getAllBikes() async {
    debugPrint('Getting all bikes');
    try {
      QuerySnapshot querySnapshot = await _bikesCollection.orderBy('name').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        return Bike.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting bikes: $e');
      return [];
    }
  }

  // Get only available bikes (operational)
  Future<List<Bike>> getAvailableBikes() async {
    try {
      QuerySnapshot querySnapshot = await _bikesCollection.where('status', isEqualTo: 'operational').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        return Bike.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting available bikes: $e');
      return [];
    }
  }

  // Count available bikes (operational)
  Future<int> countAvailableBikes() async {
    try {
      QuerySnapshot querySnapshot = await _bikesCollection.where('status', isEqualTo: 'operational').get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error counting available bikes: $e');
      return 0;
    }
  }

  // Set bike status to available
  Future<String> setBikeStatusAvailable(String id) async {
    return _setBikeStatus(id, BikeState.available);
  }

  // Set bike status to inUse
  Future<String> setBikeStatusInUse(String id) async {
    return _setBikeStatus(id, BikeState.inUse);
  }

  // Set bike status to maintenance
  Future<String> setBikeStatusMaintenance(String id) async {
    return _setBikeStatus(id, BikeState.maintenance);
  }

  // Set bike status to lost
  Future<String> setBikeStatusLost(String id) async {
    return _setBikeStatus(id, BikeState.lost);
  }

  // Helper method to set bike status
  Future<String> _setBikeStatus(String id, BikeState status) async {
    try {
      await _bikesCollection.doc(id).update({'status': status.toString().split('.').last});
      return 'Bike status updated to ${status.toString().split('.').last}';
    } catch (e) {
      return 'Error updating bike status: $e';
    }
  }

  // Get bikes with no associated station, ordered by name
  Future<List<Bike>> getBikesWithNoStation() async {
    try {
      // Query for bikes with stationReference as empty string and order by name
      QuerySnapshot querySnapshot = await _bikesCollection
          .where('stationReference', isEqualTo: '')
          .get();

      // Debug print all the bikes with no station
      for (var doc in querySnapshot.docs) {
        debugPrint('Bike with no station: ${doc.data()}');
      }

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No bikes found with no station.');
      }

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        debugPrint('Data: $data');
        return Bike.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting bikes with no station: $e');
      return [];
    }
  }
}