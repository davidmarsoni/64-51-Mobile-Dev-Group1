import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:valais_roll/data/enums/bikeState.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/repository/station_repository.dart';

class BikeRepository {
  final CollectionReference _bikesCollection = FirebaseFirestore.instance.collection('bikes');

  // CRUD operations

  // Add a new bike
  Future<String> addBike(Bike bike) async {
    try {
      DocumentReference docRef = await _bikesCollection.add(bike.toJson());
      bike.id = docRef.id; 
      if (bike.stationReference.isNotEmpty) {
        await addBikeRefToStation(bike.stationReference, bike.id!);
      }
      return 'Bike added successfully';
    } catch (e) {
      return 'Error adding bike: $e';
    }
  }

  // Update an existing bike
  Future<String> updateBike(Bike bike) async {
    try {
      if (bike.id == null) {
        throw Exception('Bike ID is null');
      }

      Bike? previousBike = await getBikeById(bike.id!);
      if (previousBike == null) {
        throw Exception('Previous bike data not found');
      }

      if (previousBike.stationReference.isNotEmpty) {
        await removeBikeRefToStation(previousBike.stationReference, bike.id!);
      }

      await _bikesCollection.doc(bike.id!).update(bike.toJson());

      if (bike.stationReference.isNotEmpty) {
        await addBikeRefToStation(bike.stationReference, bike.id!);
      }

      return 'Bike updated successfully';
    } catch (e) {
      return 'Error updating bike: $e';
    }
  }

  // Delete a bike
  Future<String> deleteBike(Bike bike) async {
    try {
      if (bike.id == null) {
        throw Exception('Bike ID is null');
      }

      if (bike.stationReference.isNotEmpty) {
        debugPrint('Removing bike reference from station: ${bike.stationReference}');
        debugPrint('Bike ID: ${bike.id}');
        await removeBikeRefToStation(bike.stationReference, bike.id!);
      }

      await _bikesCollection.doc(bike.id!).delete();
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

  // Get a bike by number
  Future<Bike?> getBikeByNbr(String number) async {
    try {
      DocumentSnapshot doc = await _bikesCollection.doc(number).get();
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
      QuerySnapshot querySnapshot = await _bikesCollection.where('status', isEqualTo: BikeState.available.index).get();
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
      QuerySnapshot querySnapshot = await _bikesCollection.where('status', isEqualTo: BikeState.available.index).get();
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

  // Station-related operations

  // Add bike reference to station
  Future<void> addBikeRefToStation(String stationReference, String bikeId) async {
    final stationRepository = StationRepository();
    await stationRepository.addBikeRef(stationReference, bikeId);
  }

  // Remove bike reference from station
  Future<void> removeBikeRefToStation(String stationReference, String bikeId) async {
    final stationRepository = StationRepository();
    await stationRepository.removeBikeRef(stationReference, bikeId);
  }

  // Add station reference to bike
  Future<void> addStationRefToBike(String bikeId, String stationId) async {
    try {
      await _bikesCollection.doc(bikeId).update({'stationReference': stationId});
    } catch (e) {
      print('Error adding station reference to bike: $e');
    }
  }

  // Remove station reference from bike
  Future<void> removeStationRefFromBike(String bikeId) async {
    try {
      await _bikesCollection.doc(bikeId).update({'stationReference': ''});
    } catch (e) {
      print('Error removing station reference from bike: $e');
    }
  }

  // Get bikes with no associated station, ordered by name
  Future<List<Bike>> getBikesWithNoStation() async {
    try {
      QuerySnapshot querySnapshot = await _bikesCollection
          .where('stationReference', isEqualTo: '')
          .get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        
        return Bike.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get available bikes for a station 
  Future<List<Bike>> getAvailableBikesForStation(String stationId) async {
    try {
      QuerySnapshot querySnapshot = await _bikesCollection.where('stationReference', isEqualTo: stationId).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        return Bike.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Check and return if a bike is available for use on a station with its number
   Future<String?> isBikeAvailableForUse(String bikeNumber, String stationId) async {
    try {
      QuerySnapshot querySnapshot = await _bikesCollection
          .where('number', isEqualTo: bikeNumber)
          .where('stationReference', isEqualTo: stationId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      print('Error checking bike availability: $e');
    }
    return null;
  }
}