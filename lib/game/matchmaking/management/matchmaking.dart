import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
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
      if (response.total >= maxPlayersPerRoom) {
        _currentCheckingRoom++;
        continue;
      }
      return _currentCheckingRoom;
    } on AppwriteException {
      return _currentCheckingRoom;
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

Future<String> _addPlayerToRoom(
    int room, String userEmail, String userName) async {
  final String _documentId = ID.unique();
  // Adds the current user to the first open room
  await databases.createDocument(
    databaseId: appDatabase,
    collectionId: matchmakingCollection,
    documentId: _documentId,
    data: {'room_id': room, 'user_email': userEmail, "user_name": userName},
  );
  return _documentId;
}

Future<void> removePlayerFromRoom(
    BuildContext context, String documentId) async {
  // Removes the current user from the room
  logger.i("Removed Player From Room $documentId");
  await databases.deleteDocument(
    databaseId: appDatabase,
    collectionId: matchmakingCollection,
    documentId: documentId,
  );
  logger.i("Removed Player From Room $documentId");
  logger.d("Navigating Home");
}

Future<List<String>> _getAllPlayersInRoom(int roomID) async {
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: matchmakingCollection,
      queries: [
        Query.equal('room_id', roomID),
      ]);
  List<String> _allPlayersInRoom = response.documents
      .map((document) => document.data['user_name'] as String)
      .toList();
  return _allPlayersInRoom;
}

Future<void> startGame(BuildContext context, User user) async {
  logger.d("Joining Room");
  if (await _userIsInRoom(user.email)) {
    logger.i("User is already in a room");
    return;
  }
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text("Joining matchmaking")));
  int _currentRoom = await _getOpenMatchmakingRoom();
  logger.d("Open Room Found $_currentRoom");
  String _documentId =
      await _addPlayerToRoom(_currentRoom, user.email, user.name);
  List<String> _allPlayersInRoom = await _getAllPlayersInRoom(_currentRoom);
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WaitRoom(
          playerNames: _allPlayersInRoom,
          user: user,
          documentId: _documentId,
          roomID: _currentRoom,
        ),
      ));
}
