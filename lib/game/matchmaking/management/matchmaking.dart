import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import '../../../enums/appwrite.dart';
import '../../../main.dart';
import '../Widgets/WaitingForPlayers.dart';
import '../config.dart';

Future<int> _getOpenMatchmakingRoom({bool isOutdoor = true}) async {
  int currentCheckingRoom = 1;

  while (true) {
    try {
      final response = await databases.listDocuments(
        databaseId: appDatabase,
        collectionId: matchmakingCollection,
        queries: [
          Query.equal('room_id', currentCheckingRoom),
        ],
      );
      print(
          'Checking room $currentCheckingRoom: ${response.total} players found.');
      if (response.total >= maxPlayersPerRoom) {
        currentCheckingRoom++;
        continue;
      }
      if (response.total == 0) {
        return currentCheckingRoom;
      }
      if (await _roomIsOutdoor(currentCheckingRoom) == isOutdoor) {
        return currentCheckingRoom;
      }
      currentCheckingRoom++;
    } on AppwriteException catch (e) {
      logger.e(e.message);
      return currentCheckingRoom;
    }
  }
}

Future<bool> _roomIsOutdoor(int roomID) async {
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: matchmakingCollection,
      queries: [
        Query.equal('room_id', roomID),
      ]);
  return response.documents[0].data['is_outdoor'] as bool;
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
    int room, String userEmail, String userName, bool isOutdoor) async {
  final String documentId = ID.unique();
  // Adds the current user to the first open room with matching criteria
  await databases.createDocument(
    databaseId: appDatabase,
    collectionId: matchmakingCollection,
    documentId: documentId,
    data: {
      'room_id': room,
      'user_email': userEmail,
      "user_name": userName,
      "is_outdoor": isOutdoor
    },
  );
  return documentId;
}

Future<void> removePlayerFromRoom(
    BuildContext context, String documentId) async {
  // Removes the current user from the room
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
  List<String> allPlayersInRoom = response.documents
      .map((document) => document.data['user_name'] as String)
      .toList();
  return allPlayersInRoom;
}

Future<void> startGame(BuildContext context, User user,
    {bool isOutdoor = true}) async {
  logger.d("Joining Room");
  if (await _userIsInRoom(user.email)) {
    logger.w("User is already in a room");
    return;
  }
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text("Joining matchmaking")));
  int currentRoom = await _getOpenMatchmakingRoom(isOutdoor: isOutdoor);
  logger.d("Open Room Found $currentRoom");
  String documentId =
      await _addPlayerToRoom(currentRoom, user.email, user.name, isOutdoor);
  List<String> allPlayersInRoom = await _getAllPlayersInRoom(currentRoom);
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WaitRoom(
          playerNames: allPlayersInRoom,
          user: user,
          documentId: documentId,
          roomID: currentRoom,
        ),
      ));
}
