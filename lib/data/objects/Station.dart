import 'package:cloud_firestore/cloud_firestore.dart';

class Station {
  final String? id;
  final String? name;
  final GeoPoint? coordinates;
  final String? address;
  final List<String> bikeReferences;

  Station({
    this.id,
    this.name,
    this.coordinates,
    this.address,
    this.bikeReferences = const [],
  });

  // Method to convert Station object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coordinates': coordinates,
      'address': address,
      'bikeReferences': bikeReferences,
    };
  }

  // Method to create Station object from JSON
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'] ?? 'Unknown Name',
      coordinates: json['coordinates'],
      address: json['address'] ?? 'Unknown Address',
      bikeReferences: json['bikeReferences'] != null ? List<String>.from(json['bikeReferences']) : [],
    );
  }
}