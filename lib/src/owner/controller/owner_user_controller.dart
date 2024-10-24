import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/app_user.dart';
import 'package:valais_roll/data/objects/history.dart';
import 'package:valais_roll/data/repository/app_user_repository.dart';
import 'package:valais_roll/data/repository/history_repository.dart';

class OwnerUserController extends ChangeNotifier {
  final AppUserRepository _userRepository = AppUserRepository();
  final HistoryRepository _historyRepository = HistoryRepository();
  List<AppUser> _users = [];
  List<AppUser> _allUsers = []; // Store all users
  List<History> userHistory = [];
  AppUser? _selectedUser;
  String _searchQuery = '';

  List<AppUser> get users => _users;
  AppUser? get selectedUser => _selectedUser;

  OwnerUserController() {
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    _allUsers = await _userRepository.getAllUsers();
    _filterUsers();
  }

  void selectUser(AppUser user) {
    _selectedUser = user;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterUsers();
  }

  void _filterUsers() {
    if (_searchQuery.isEmpty) {
      _users = _allUsers;
    } else {
      _users = _allUsers.where((user) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               user.surname.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchUserHistory(String userId) async {
    userHistory = await _historyRepository.getHistoryByUser(userId);
    notifyListeners();
  }

}