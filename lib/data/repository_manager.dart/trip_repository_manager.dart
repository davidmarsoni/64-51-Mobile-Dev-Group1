import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valais_roll/data/enums/bikeState.dart';
import 'package:valais_roll/data/repository/history_repository.dart';
import 'package:valais_roll/data/repository/station_history_repository.dart';
import 'package:valais_roll/data/repository/bike_repository.dart';
import 'package:valais_roll/data/repository/station_repository.dart';
import 'package:valais_roll/data/enums/station_histroy_status.dart';

class TripRepositoryManager {
  final HistoryRepository _historyRepository = HistoryRepository();
  final StationHistoryRepository _stationHistoryRepository = StationHistoryRepository();
  final BikeRepository _bikeRepository = BikeRepository();
  final StationRepository _stationRepository = StationRepository();

  Future<String> startTrip(String userRef, String bikeRef, String startStationRef) async {
    try {
      // Verification part

      // Verify that the user has no active trip
      String? lastHistory = await _historyRepository.getLastHistory(userRef);

      if (lastHistory != null) {
        return 'User already has an active trip';
      }

      // Verify that the bike is available and it is in the station of the departure
      var bike = await _bikeRepository.getBikeById(bikeRef);
      if (bike == null) {
        return 'Bike not found';
      }
      if (bike.bike_state != BikeState.available) {
        return 'Bike is not available';
      }

      if (bike.stationReference != startStationRef) {
        return 'Bike is not in start station';
      }

      // Create history
      await _historyRepository.createHistory(startStationRef, bikeRef, userRef);

      // Create station history for pickup
      await _stationHistoryRepository.createHistory(startStationRef, userRef, bikeRef, StationHistoryStatus.pickup);

      // Remove station reference from bike and bike reference from station
      await _bikeRepository.removeStationRefFromBike(bikeRef);
      await _stationRepository.removeBikeRef(startStationRef, bikeRef);

      // Set the bike state to in use
      await _bikeRepository.setBikeStatusInUse(bikeRef);

      return 'Trip started successfully';
    } catch (e) {
      return 'Error starting trip: $e';
    }
  }

  Future<String> addInterestPoint(String userRef, GeoPoint interestPoint) async {
    try {
      // Get the last history for the user
      String? historyId = await _historyRepository.getLastHistory(userRef);
      if (historyId == null) {
        return 'No active trip found for the user';
      }
      // Add interest point to history
      await _historyRepository.addInterestPoint(historyId, interestPoint);
      return 'Interest point added successfully';
    } catch (e) {
      return 'Error adding interest point: $e';
    }
  }

  Future<String> endTrip(String userRef, String bikeRef, String endStationRef) async {
    try {
      // Get the last history for the user
      String? historyId = await _historyRepository.getLastHistory(userRef);
      if (historyId == null) {
        return 'No active trip found for the user';
      }

      // End history
      await _historyRepository.endHistory(historyId, endStationRef);

      // Create station history for deposit
      await _stationHistoryRepository.createHistory(endStationRef, userRef, bikeRef, StationHistoryStatus.deposit);

      // Add station reference to bike and bike reference to station
      await _bikeRepository.addStationRefToBike(bikeRef, endStationRef);
      await _stationRepository.addBikeRef(endStationRef, bikeRef);

      // Set the bike state to available
      await _bikeRepository.setBikeStatusAvailable(bikeRef);

      return 'Trip ended successfully';
    } catch (e) {
      return 'Error ending trip: $e';
    }
  }
}