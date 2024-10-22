import 'package:cloud_firestore/cloud_firestore.dart';

class History {
  String? id;
  String startStationRef;
  String bikeRef;
  String userRef;
  List<GeoPoint> interestPoints;
  String? endStationRef;
  DateTime startTime;
  DateTime? endTime;

  History({
    this.id,
    required this.startStationRef,
    required this.bikeRef,
    required this.userRef,
    this.interestPoints = const [],
    this.endStationRef,
    required this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'startStationRef': startStationRef,
      'bikeRef': bikeRef,
      'userRef': userRef,
      'interestPoints': interestPoints.map((point) => {'latitude': point.latitude, 'longitude': point.longitude}).toList(),
      'endStationRef': endStationRef,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'],
      startStationRef: json['startStationRef'],
      bikeRef: json['bikeRef'],
      userRef: json['userRef'],
      interestPoints: (json['interestPoints'] as List).map((point) => GeoPoint(point['latitude'], point['longitude'])).toList(),
      endStationRef: json['endStationRef'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}