import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:valais_roll/data/objects/history.dart';

class HistoryRepository {
  final CollectionReference _historyCollection = FirebaseFirestore.instance.collection('history');

  Future<String> createHistory(String startStationRef, String bikeRef, String userRef) async {
    try {
      History history = History(
        startStationRef: startStationRef,
        bikeRef: bikeRef,
        userRef: userRef,
        startTime: DateTime.now(),
      );
      DocumentReference docRef = await _historyCollection.add(history.toJson());
      return docRef.id;
    } catch (e) {
      return 'Error creating history: $e';
    }
  }

  Future<String> addInterestPoint(String historyId, GeoPoint interestPoint) async {
    try {
      await _historyCollection.doc(historyId).update({
        'interestPoints': FieldValue.arrayUnion([{'latitude': interestPoint.latitude, 'longitude': interestPoint.longitude}])
      });
      return 'Interest point added successfully';
    } catch (e) {
      return 'Error adding interest point: $e';
    }
  }

  Future<String> endHistory(String historyId, String endStationRef) async {
    try {
      await _historyCollection.doc(historyId).update({
        'endStationRef': endStationRef,
        'endTime': DateTime.now().toIso8601String(),
      });
      return 'History ended successfully';
    } catch (e) {
      return 'Error ending history: $e';
    }
  }

  Future<History?> getHistoryById(String id) async {
    try {
      DocumentSnapshot doc = await _historyCollection.doc(id).get();
      if (doc.exists) {
        return History.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching history by ID: $e');
    }
    return null;
  }

  Future<List<History>> getHistoryByUser(String userRef) async {
    try {
      QuerySnapshot querySnapshot = await _historyCollection.where('userRef', isEqualTo: userRef).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return History.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<History>> getHistoryByBike(String bikeRef) async {
    try {
      QuerySnapshot querySnapshot = await _historyCollection.where('bikeRef', isEqualTo: bikeRef).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return History.fromJson(data);
      }).toList();
    } catch (e) {
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
        debugPrint('querySnapshot.docs.isNotEmpty22: ${querySnapshot.docs.isNotEmpty}');
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      print('Error fetching last history by user: $e');
    }
    return null;
  }
}