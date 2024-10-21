import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valais_roll/data/objects/user_history.dart';
import 'package:valais_roll/data/repository/user_history_repository.dart';
import 'package:valais_roll/data/repository/station_history_repository.dart';
import 'package:valais_roll/data/repository/bike_history_repository.dart';
import 'package:valais_roll/data/repository/bike_repository.dart';
import 'package:valais_roll/data/repository/station_repository.dart';
import 'package:valais_roll/data/enums/station_histroy_status.dart';

class TripRepositoryManager {
  final UserHistoryRepository _userHistoryRepository = UserHistoryRepository();
  final StationHistoryRepository _stationHistoryRepository = StationHistoryRepository();
  final BikeHistoryRepository _bikeHistoryRepository = BikeHistoryRepository();
  final BikeRepository _bikeRepository = BikeRepository();
  final StationRepository _stationRepository = StationRepository();

  Future<String> startTrip(String userRef, String bikeRef, String startStationRef) async {
    try {
      // Create user history
      String userHistoryId = await _userHistoryRepository.createHistory(startStationRef, bikeRef, userRef);

      // Create station history for pickup
      await _stationHistoryRepository.createHistory(startStationRef, userRef, bikeRef, StationHistoryStatus.pickup);

      // Create bike history
      String bikeHistoryId = await _bikeHistoryRepository.createHistory(userRef, bikeRef, startStationRef);

      // Remove station reference from bike and bike reference from station
      await _bikeRepository.removeStationRefFromBike(bikeRef);
      await _stationRepository.removeBikeRef(startStationRef, bikeRef);

      //set the bike state to in use
      await _bikeRepository.setBikeStatusInUse(bikeRef);

     

      return 'Trip started successfully with UserHistory ID: $userHistoryId and BikeHistory ID: $bikeHistoryId';
    } catch (e) {
      return 'Error starting trip: $e';
    }
  }

  Future<String> addInterestPoint(String userHistoryId, GeoPoint interestPoint) async {
    try {
      // Add interest point to user history
      await _userHistoryRepository.addInterestPoint(userHistoryId, interestPoint);

      // Get the last bike history for the user
      UserHistory? userHistory = await _userHistoryRepository.getHistoryById(userHistoryId);
      if (userHistory != null) {
        await _bikeHistoryRepository.addInterestPoint(userHistory.bikeRef, interestPoint);
      }

      return 'Interest point added successfully';
    } catch (e) {
      return 'Error adding interest point: $e';
    }
  }

  Future<String> endTrip(String userRef, String bikeRef, String endStationRef) async {
    try {
      // Get the last user history for the user
      String? userHistoryId = await _userHistoryRepository.getLastHistory(userRef);
      if (userHistoryId == null) {
        return 'No active trip found for the user';
      }

      // End user history
      await _userHistoryRepository.endHistory(userHistoryId, endStationRef);

      // Get the last bike history for the user
      UserHistory? userHistory = await _userHistoryRepository.getHistoryById(userHistoryId);
      if (userHistory != null) {
        await _bikeHistoryRepository.endHistory(userHistory.bikeRef, endStationRef);
      }

      // Create station history for deposit
      await _stationHistoryRepository.createHistory(endStationRef, userRef, userHistory!.bikeRef, StationHistoryStatus.deposit);

      // Add station reference to bike and bike reference to station
      await _bikeRepository.addStationRefToBike(bikeRef, endStationRef);
      await _stationRepository.addBikeRef(endStationRef, bikeRef);

      //set the bike state to available
      await _bikeRepository.setBikeStatusAvailable(bikeRef);

      return 'Trip ended successfully';
    } catch (e) {
      return 'Error ending trip: $e';
    }
  }
}