import 'package:cloud_firestore/cloud_firestore.dart';

class BikeHistory {
  String? id;
  String userRef;
  String bikeRef;
  DateTime startTime;
  DateTime? endTime;
  String startStationRef;
  String? endStationRef;
  List<GeoPoint> interestPoints;

  BikeHistory({
    this.id,
    required this.userRef,
    required this.bikeRef,
    required this.startTime,
    this.endTime,
    required this.startStationRef,
    this.endStationRef,
    this.interestPoints = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'userRef': userRef,
      'bikeRef': bikeRef,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'startStationRef': startStationRef,
      'endStationRef': endStationRef,
      'interestPoints': interestPoints.map((point) => {'latitude': point.latitude, 'longitude': point.longitude}).toList(),
    };
  }

  factory BikeHistory.fromJson(Map<String, dynamic> json) {
    return BikeHistory(
      id: json['id'],
      userRef: json['userRef'],
      bikeRef: json['bikeRef'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      startStationRef: json['startStationRef'],
      endStationRef: json['endStationRef'],
      interestPoints: (json['interestPoints'] as List).map((point) => GeoPoint(point['latitude'], point['longitude'])).toList(),
    );
  }
}