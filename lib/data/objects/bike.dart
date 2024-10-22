import 'package:flutter/material.dart';
import 'package:valais_roll/data/enums/bikeState.dart';

class Bike {
  String? id; // Add an ID field
  String name;
  String model;
  String number;
  BikeState bike_state;
  String stationReference;

  Bike({
    this.id,
    required this.name,
    required this.model,
    required this.number,
    required this.bike_state,
    required this.stationReference,
  });

  // Method to convert Bike object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'number': number,
      'status': bike_state.toString().split('.').last,
      'stationReference': stationReference,
    };
  }

  // Method to create Bike object from JSON
  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: json['id'],
      name: json['name'],
      model: json['model'],
      number: json['number'],
      bike_state: BikeState.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      stationReference: json['stationReference'],
    );
  }
}