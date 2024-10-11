import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/Bike.dart';
import 'package:valais_roll/data/enums/Status.dart';

class BikeRepository {
  final CollectionReference _bikesCollection = FirebaseFirestore.instance.collection('bikes');

  // Add a new bike
  Future<String> addBike(Bike bike, BuildContext context) async {
    try {
      await _bikesCollection.add(bike.toJson());
      return 'Bike added successfully';
    } catch (e) {
      _showSnackBar(context, 'Error adding bike: $e');
      return 'Error adding bike: $e';
    }
  }

  // Update an existing bike
  Future<String> updateBike(String id, Bike bike, BuildContext context) async {
    try {
      await _bikesCollection.doc(id).update(bike.toJson());
      return 'Bike updated successfully';
    } catch (e) {
      _showSnackBar(context, 'Error updating bike: $e');
      return 'Error updating bike: $e';
    }
  }

  // Delete a bike
  Future<String> deleteBike(String id, BuildContext context) async {
    try {
      await _bikesCollection.doc(id).delete();
      return 'Bike deleted successfully';
    } catch (e) {
      _showSnackBar(context, 'Error deleting bike: $e');
      return 'Error deleting bike: $e';
    }
  }

  // Get a bike by ID
  Future<Bike?> getBikeById(String id, BuildContext context) async {
    try {
      DocumentSnapshot doc = await _bikesCollection.doc(id).get();
      if (doc.exists) {
        return Bike.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      _showSnackBar(context, 'Error getting bike: $e');
    }
    return null;
  }

  // Get all bikes
  Future<List<Bike>> getAllBikes(BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await _bikesCollection.get();
      return querySnapshot.docs.map((doc) => Bike.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      _showSnackBar(context, 'Error getting bikes: $e');
      return [];
    }
  }

  // Get only available bikes (operational)
  Future<List<Bike>> getAvailableBikes(BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await _bikesCollection.where('status', isEqualTo: 'operational').get();
      return querySnapshot.docs.map((doc) => Bike.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      _showSnackBar(context, 'Error getting available bikes: $e');
      return [];
    }
  }

  // Count available bikes (operational)
  Future<int> countAvailableBikes(BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await _bikesCollection.where('status', isEqualTo: 'operational').get();
      return querySnapshot.docs.length;
    } catch (e) {
      _showSnackBar(context, 'Error counting available bikes: $e');
      return 0;
    }
  }

  // Set bike status to damaged
  Future<String> setBikeStatusDamaged(String id, BuildContext context) async {
    return _setBikeStatus(id, Status.damaged, context);
  }

  // Set bike status to repair
  Future<String> setBikeStatusRepair(String id, BuildContext context) async {
    return _setBikeStatus(id, Status.repair, context);
  }

  // Set bike status to operational
  Future<String> setBikeStatusOperational(String id, BuildContext context) async {
    return _setBikeStatus(id, Status.operational, context);
  }

  // Helper method to set bike status
  Future<String> _setBikeStatus(String id, Status status, BuildContext context) async {
    try {
      await _bikesCollection.doc(id).update({'status': status.toString().split('.').last});
      return 'Bike status updated to ${status.toString().split('.').last}';
    } catch (e) {
      _showSnackBar(context, 'Error updating bike status: $e');
      return 'Error updating bike status: $e';
    }
  }

  // Helper method to show SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}