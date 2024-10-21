import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valais_roll/data/objects/bike_history.dart';

class BikeHistoryRepository {
    final CollectionReference _historyCollection = FirebaseFirestore.instance.collection('bike_history');

    Future<String> createHistory(String userRef, String bikeRef, String startStationRef) async {
        try {
        BikeHistory history = BikeHistory(
            userRef: userRef,
            bikeRef: bikeRef,
            startTime: DateTime.now(),
            startStationRef: startStationRef,
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

    Future<BikeHistory?> getHistoryById(String id) async {
        try {
        DocumentSnapshot doc = await _historyCollection.doc(id).get();
        if (doc.exists) {
            return BikeHistory.fromJson(doc.data() as Map<String, dynamic>);
        }
        } catch (e) {
        print('Error fetching history by ID: $e');
        }
        return null;
    }

    Future<List<BikeHistory>> getHistory(String bikeRef) async {
        try {
        QuerySnapshot querySnapshot = await _historyCollection.where('bikeRef', isEqualTo: bikeRef).get();
        return querySnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return BikeHistory.fromJson(data);
        }).toList();
        } catch (e) {
        return [];
        }
    }


    Future<BikeHistory?> getLastHistoryByBike(String bikeRef) async {
        try {
        QuerySnapshot querySnapshot = await _historyCollection.where('bikeRef', isEqualTo: bikeRef).orderBy('startTime',descending: true).limit(1).get();
        if(querySnapshot.docs.isNotEmpty){
            return BikeHistory.fromJson(querySnapshot.docs.first.data() as Map<String, dynamic>);
        }
        } catch (e) {
        print('Error fetching history by ID: $e');
        }
        return null;
    }
}