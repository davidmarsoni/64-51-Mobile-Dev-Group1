import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:valais_roll/data/objects/history.dart';
import 'package:valais_roll/data/objects/Station.dart';
import 'package:valais_roll/data/repository/station_repository.dart';

class HistoryRepository {
  final CollectionReference _historyCollection = FirebaseFirestore.instance.collection('history');
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference _bikeCollection = FirebaseFirestore.instance.collection('bikes');
  final StationRepository _stationRepository = StationRepository();

  Future<String> createHistory(String startStationRef, String bikeRef, String userRef) async {
    try {
      History history = History(
        startStationRef: startStationRef,
        bikeRef: bikeRef,
        userRef: userRef,
        startTime: DateTime.now(),
      );
      DocumentReference docRef = await _historyCollection.add(history.toJson());
      debugPrint('History created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating history: $e');
      return 'Error creating history: $e';
    }
  }

  Future<String> addInterestPoint(String historyId, GeoPoint interestPoint) async {
    try {
      await _historyCollection.doc(historyId).update({
        'interestPoints': FieldValue.arrayUnion([{'latitude': interestPoint.latitude, 'longitude': interestPoint.longitude}])
      });
      debugPrint('Interest point added to history ID: $historyId');
      return 'Interest point added successfully';
    } catch (e) {
      debugPrint('Error adding interest point: $e');
      return 'Error adding interest point: $e';
    }
  }

  Future<String> endHistory(String historyId, String endStationRef) async {
    try {
      await _historyCollection.doc(historyId).update({
        'endStationRef': endStationRef,
        'endTime': DateTime.now().toIso8601String(),
      });
      debugPrint('History ended with ID: $historyId');
      return 'History ended successfully';
    } catch (e) {
      debugPrint('Error ending history: $e');
      return 'Error ending history: $e';
    }
  }

  Future<History?> getHistoryById(String id) async {
    try {
      DocumentSnapshot doc = await _historyCollection.doc(id).get();
      if (doc.exists) {
        debugPrint('History fetched by ID: $id');
        return History.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error fetching history by ID: $e');
    }
    return null;
  }

   Future<List<History>> getHistoryByUser(String userRef) async {
    try {
      QuerySnapshot querySnapshot = await _historyCollection.where('userRef', isEqualTo: userRef).get();
      List<History> histories = await Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        History history = History.fromJson(data);

        // Fetch related station name and coordinates using StationRepository
        debugPrint('Start station ref: ${history.startStationRef}');
        Station? startStation = await _stationRepository.getStationById(history.startStationRef);
        if (startStation != null) {
          history.startStationName = startStation.name;
          history.startStationCoordinates = startStation.coordinates;
        }

        if (history.endStationRef != null) {
          Station? endStation = await _stationRepository.getStationById(history.endStationRef!);
          if (endStation != null) {
            history.endStationName = endStation.name;
            history.endStationCoordinates = endStation.coordinates;
          }
        }

        // Fetch related bike name
        DocumentSnapshot bikeDoc = await _bikeCollection.doc(history.bikeRef).get();
        if (bikeDoc.exists) {
          history.bikeName = bikeDoc['name'];
        }

        debugPrint('History fetched for user: $userRef, History ID: ${history.id}');
        return history;
      }).toList());

      return histories;
    } catch (e) {
      debugPrint('Error fetching history by user: $e');
      return [];
    }
  }

 Future<List<History>> getHistoryByBike(String bikeRef) async {
    try {
      QuerySnapshot querySnapshot = await _historyCollection.where('bikeRef', isEqualTo: bikeRef).get();
      List<History> histories = await Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        History history = History.fromJson(data);

        // Fetch related user name
        DocumentSnapshot userDoc = await _userCollection.doc(history.userRef).get();
        if (userDoc.exists) {
          history.userName = userDoc['name'];
        }

        // Fetch related start station name
        Station? startStation = await _stationRepository.getStationById(history.startStationRef);
        if (startStation != null) {
          history.startStationName = startStation.name;
        }

        // Fetch related end station name
        if (history.endStationRef != null) {
          Station? endStation = await _stationRepository.getStationById(history.endStationRef!);
          if (endStation != null) {
            history.endStationName = endStation.name;
          }
        }

        debugPrint('History fetched for bike: $bikeRef, History ID: ${history.id}');
        return history;
      }).toList());

      return histories;
    } catch (e) {
      debugPrint('Error fetching history by bike: $e');
      return [];
    }
  }
  
  Future<String?> getLastHistory(String userRef) async {
    try {
      // First, check for histories where endTime is null
      QuerySnapshot querySnapshot = await _historyCollection
          .where('userRef', isEqualTo: userRef)
          .where('endTime', isNull: true)
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('Last history with endTime null found for user: $userRef');
        return querySnapshot.docs.first.id;
      }

      // If no history with endTime null is found, check for history with interestPoint not null
      querySnapshot = await _historyCollection
          .where('userRef', isEqualTo: userRef)
          .where('interestPoint', isNull: false)
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('Last history with interestPoint not null found for user: $userRef');
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      debugPrint('Error fetching last history by user: $e');
    }
    return null;
  }
}