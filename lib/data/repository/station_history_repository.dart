import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valais_roll/data/enums/station_histroy_status.dart';
import 'package:valais_roll/data/objects/station_history.dart';

class StationHistoryRepository {
  final CollectionReference _historyCollection = FirebaseFirestore.instance.collection('station_history');

  Future<String> createHistory(String stationRef, String userRef, String bikeRef, StationHistoryStatus status) async {
    try {
      StationHistory history = StationHistory(
        stationRef: stationRef,
        userRef: userRef,
        time: DateTime.now(),
        bikeRef: bikeRef,
        status: status,
      );
      DocumentReference docRef = await _historyCollection.add(history.toJson());
      return docRef.id;
    } catch (e) {
      return 'Error creating history: $e';
    }
  }

  Future<List<StationHistory>> getHistory(String stationRef) async {
    try {
      QuerySnapshot querySnapshot = await _historyCollection.where('stationRef', isEqualTo: stationRef).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return StationHistory.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
