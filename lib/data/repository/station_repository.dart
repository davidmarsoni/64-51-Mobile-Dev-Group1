import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:valais_roll/data/enums/bikeState.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/data/objects/bike.dart';
import 'package:valais_roll/data/repository/bike_repository.dart';

class StationRepository {
  final CollectionReference _stationsCollection = FirebaseFirestore.instance.collection('stations_test');
  final BikeRepository _bikeRepository = BikeRepository();

  Future<List<Station>> getAllStations() async {
    try {
      QuerySnapshot querySnapshot = await _stationsCollection.get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        return Station.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> addStation(Station station) async {
    try {
      // Add the station to the collection and get the document reference
      DocumentReference docRef = await _stationsCollection.add(station.toJson());
  
      // Get the newly added station's ID
      String stationId = docRef.id;
  
      // Update the bikes with the station reference
      for (var bikeref in station.bikeReferences) {
        if (bikeref.isNotEmpty) {
          await _bikeRepository.addStationRefToBike(bikeref, stationId);
        }
      }
  
      return 'Station added successfully';
    } catch (e) {
      return 'Error adding station: $e';
    }
  }

  Future<String> updateStation(String id, Station station) async {
    try {
      // Retrieve the previous station data
      DocumentSnapshot docSnapshot = await _stationsCollection.doc(id).get();
      Station previousStation = Station.fromJson(docSnapshot.data() as Map<String, dynamic>);
  
      // Remove the station reference from the previous bikes
      for (var previousBikeRef in previousStation.bikeReferences) {
        if (previousBikeRef.isNotEmpty) {
          debugPrint('Previous bike ref: $previousBikeRef');
          await _bikeRepository.removeStationRefFromBike(previousBikeRef);
        }
      }
  
      // Update the newly added bikes with the station reference
      for (var newBikeRef in station.bikeReferences) {
        if (newBikeRef.isNotEmpty) {
          debugPrint('New bike ref: $newBikeRef');
          await _bikeRepository.addStationRefToBike(newBikeRef, station.id!);
        }
      }
  
      // Update the station in the collection
      await _stationsCollection.doc(id).update(station.toJson());
      return 'Station updated successfully';
    } catch (e) {
      return 'Error updating station: $e';
    }
  }

  Future<String> deleteStation(String id) async {
    try {
      debugPrint('Deleting station with ID: $id');
      // Retrieve the station data to get the bike references
      DocumentSnapshot docSnapshot = await _stationsCollection.doc(id).get();
      if (docSnapshot.exists) {
        Station station = Station.fromJson(docSnapshot.data() as Map<String, dynamic>);
  
        // Remove the station reference from each bike
        for (var bikeRef in station.bikeReferences) {
          if (bikeRef.isNotEmpty) {
            await _bikeRepository.removeStationRefFromBike(bikeRef);
          }
        }
      }
  
      // Delete the station
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

  Future<String> addBikeRef(String stationId, String bikeRef) async {
    try {
      // Update the station document to include the bike reference
      await _stationsCollection.doc(stationId).update({
        'bikeReferences': FieldValue.arrayUnion([bikeRef])
      });
      return 'Bike reference added to station successfully';
    } catch (e) {
      return 'Error adding bike reference to station: $e';
    }
  }

  Future<String> removeBikeRef(String stationId, String bikeRef) async {
    try {
      // Update the station document to remove the bike reference
      await _stationsCollection.doc(stationId).update({
        'bikeReferences': FieldValue.arrayRemove([bikeRef])
      });
      return 'Bike reference removed from station successfully';
    } catch (e) {
      return 'Error removing bike reference from station: $e';
    }
  }

  Future<int> countAvailableBikes(String stationId) async {
    try {
      int availableBikeCount = 0;
      Station? station = await getStationById(stationId);

      if (station != null) {
        for (var bikeRef in station.bikeReferences) {
          if (bikeRef.isNotEmpty) {
            Bike? bike = await _bikeRepository.getBikeById(bikeRef);
            if (bike != null && bike.bike_state == BikeState.available) {
              availableBikeCount++;
            }
          }
        }
      }

      return availableBikeCount;
    } catch (e) {
      return 0;
    }
  }
}