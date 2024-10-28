import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:SnapQuest/enums/appwrite.dart';
import '../../../../classes/Challenge.dart';
import '../../../../main.dart';

Future<String?> _writeChallengeToDB(int roomID, Challenge challenge) async {
  if (await _getChallengeFromDB(roomID) != null) {
    logger.i("Room Challenge set to ${await _getChallengeFromDB(roomID)}");
    return await _getChallengeFromDB(roomID);
  }
  final response = await databases.createDocument(
      databaseId: appDatabase,
      collectionId: roomChallengesCollection,
      documentId: ID.unique(),
      data: {
        "room_id": roomID,
        "challenge": challenge.description,
        "difficulty": challenge.difficulty,
        "is_outdoor": challenge.isOutdoor
      });
  logger.i("Room Challenge set to ${challenge.description}");
  return challenge.description;
}

Future<String?> _getChallengeFromDB(int roomID) async {
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: roomChallengesCollection,
      queries: [Query.equal('room_id', roomID)]);
  if (response.total == 0) {
    logger.i("Room Challenge isn't set");
    return null;
  }
  logger.i("Room Challenge is already set");
  return response.documents[0].data['challenge'];
}

Future<String> chooseChallenge(List<Challenge> challenges, int roomID) async {
  return (await _writeChallengeToDB(
      roomID, challenges[Random().nextInt(challenges.length)]))!;
}
