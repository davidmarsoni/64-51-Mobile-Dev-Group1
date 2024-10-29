import 'package:flutter/material.dart';
import 'package:valais_roll/data/repository/history_repository.dart';
import 'package:valais_roll/src/user/user/controller/user_controller.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'history_detail_page.dart';
import 'package:valais_roll/data/objects/history.dart';

class HistoryListPage extends StatefulWidget {
  HistoryListPage({Key? key}) : super(key: key);

  @override
  _HistoryListPageState createState() => _HistoryListPageState();
}

class _HistoryListPageState extends State<HistoryListPage> {
  final HistoryRepository _historyRepository = HistoryRepository();
  final UserController _userController = UserController();

  Future<List<History>> _fetchUserHistory() async {
    final currentUser = _userController.currentUser;
    if (currentUser != null) {
      // Fetch history for the current user's uid
      return await _historyRepository.getHistoryByUser(currentUser.uid);
    } else {
      // Handle the case where no user is logged in
      throw Exception("No user is currently signed in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Ride History',
      body: FutureBuilder<List<History>>(
        future: _fetchUserHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error fetching history"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No ride history found"));
          }

          final histories = snapshot.data!;

          return ListView.builder(
            itemCount: histories.length,
            itemBuilder: (context, index) {
              final history = histories[index];
              return ListTile(
                title: Text('Ride on ${history.startTime.toString().substring(0, 10)}'),
                subtitle: Text('Start: ${history.startStationName ?? 'Unknown'}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HistoryDetailPage(history: history),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
