import 'package:valais_roll/data/enums/Status.dart';

class Bike {
  String name;
  String model;
  Status status;
  String stationReference;

  Bike({
    required this.name,
    required this.model,
    required this.status,
    required this.stationReference,
  });

  // Method to convert Bike object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'model': model,
      'status': status.toString().split('.').last,
      'stationReference': stationReference,
    };
  }

  // Method to create Bike object from JSON
  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      name: json['name'],
      model: json['model'],
      status: Status.values.firstWhere((e) => e.toString() == 'Status.${json['status']}'),
      stationReference: json['stationReference'],
    );
  }
}