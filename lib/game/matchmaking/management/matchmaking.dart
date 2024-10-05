import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import '../../../main.dart';
import '../Widgets/WaitingForPlayers.dart';
import '../config.dart';

Future<int> _getOpenMatchmakingRoom() async {
  // Checks all open rooms and returns the first one that is not full
  int _currentCheckingRoom = 1;
  while (true) {
    try {
      final response = await databases.listDocuments(
        databaseId: appDatabase,
        collectionId: matchmakingCollection,
        queries: [
          Query.equal('room_id', _currentCheckingRoom),
        ],
      );
      if (response.total >= 10) {
        _currentCheckingRoom++;
        continue;
      }
      return _currentCheckingRoom;
    } on AppwriteException {
      return _currentCheckingRoom + 1;
    }
  }
}

Future<bool> _userIsInRoom(String userEmail) async {
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: matchmakingCollection,
      queries: [
        Query.equal('user_email', userEmail),
      ]);
  return response.total > 0;
}

Future<void> _addPlayerToRoom(
    int room, String userEmail, String userName) async {
  // Adds the current user to the first open room
  await databases.createDocument(
    databaseId: appDatabase,
    collectionId: matchmakingCollection,
    documentId: ID.unique(),
    data: {'room_id': room, 'user_email': userEmail, "user_name": userName},
  );
}

Future<void> startGame(
    BuildContext context, String userEmail, String userName) async {
  logger.d("Joining Room");
  if (await _userIsInRoom(userEmail)) {
    logger.i("User is already in a room");
    return;
  }
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text("Joining matchmaking")));
  int _currentRoom = await _getOpenMatchmakingRoom();
  logger.d("Open Room Found $_currentRoom");
  await _addPlayerToRoom(_currentRoom, userEmail, userName);
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WaitRoom(playerNames: [userName]),
      ));
}
