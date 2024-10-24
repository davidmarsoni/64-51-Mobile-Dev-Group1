import 'package:cloud_firestore/cloud_firestore.dart';

class History {
  String? id;
  String startStationRef;
  String? startStationName;
  GeoPoint? startStationCoordinates; 
  String bikeRef;
  String? bikeName;
  String userRef;
  List<GeoPoint> interestPoints;
  String? endStationRef;
  String? endStationName;
  GeoPoint? endStationCoordinates; 
  DateTime startTime;
  DateTime? endTime;

  History({
    this.id,
    required this.startStationRef,
    this.startStationName,
    this.startStationCoordinates,
    required this.bikeRef,
    this.bikeName,
    required this.userRef,
    this.interestPoints = const [],
    this.endStationRef,
    this.endStationName,
    this.endStationCoordinates, 
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