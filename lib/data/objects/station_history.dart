import 'package:valais_roll/data/enums/station_histroy_status.dart';

class StationHistory {
  String? id;
  String stationRef;
  String userRef;
  DateTime time;
  String bikeRef;
  StationHistoryStatus status;

  StationHistory({
    this.id,
    required this.stationRef,
    required this.userRef,
    required this.time,
    required this.bikeRef,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'stationRef': stationRef,
      'userRef': userRef,
      'time': time.toIso8601String(),
      'bikeRef': bikeRef,
      'status': status.toString().split('.').last,
    };
  }

  factory StationHistory.fromJson(Map<String, dynamic> json) {
    return StationHistory(
      id: json['id'],
      stationRef: json['stationRef'],
      userRef: json['userRef'],
      time: DateTime.parse(json['time']),
      bikeRef: json['bikeRef'],
      status: StationHistoryStatus.values.firstWhere((e) => e.toString() == 'StationHistoryStatus.' + json['status']),
    );
  }
}