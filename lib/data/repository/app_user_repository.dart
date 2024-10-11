import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/app_user.dart';

class AppUserRepository {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  // Add a new user
  Future<String> addUser(AppUser user, BuildContext context) async {
    try {
      await _usersCollection.add(user.toJson());
      return 'User added successfully';
    } catch (e) {
      _showSnackBar(context, 'Error adding user: $e');
      return 'Error adding user: $e';
    }
  }

  // Update an existing user
  Future<String> updateUser(String id, AppUser user, BuildContext context) async {
    try {
      await _usersCollection.doc(id).update(user.toJson());
      return 'User updated successfully';
    } catch (e) {
      _showSnackBar(context, 'Error updating user: $e');
      return 'Error updating user: $e';
    }
  }

  // Delete a user
  Future<String> deleteUser(String id, BuildContext context) async {
    try {
      await _usersCollection.doc(id).delete();
      return 'User deleted successfully';
    } catch (e) {
      _showSnackBar(context, 'Error deleting user: $e');
      return 'Error deleting user: $e';
    }
  }

  // Get a user by ID
  Future<AppUser?> getUserById(String id, BuildContext context) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(id).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      _showSnackBar(context, 'Error getting user: $e');
    }
    return null;
  }

  // Helper method to show SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}