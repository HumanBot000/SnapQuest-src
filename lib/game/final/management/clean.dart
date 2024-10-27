import 'package:appwrite/appwrite.dart';
import '../../../enums/appwrite.dart';
import '../../../main.dart';
import '../../live/management/upload.dart';

Future<void> deleteBucketFile(Uri asset) async {
  await storage.deleteFile(
      bucketId: gameMediaBucket, fileId: asset.pathSegments[5]);
}

Future<void> lockRoom(int roomID) async {
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: matchmakingCollection,
      queries: [
        Query.equal('room_id', roomID),
        Query.equal('is_locked', false),
      ]);
  for (var data in response.documents) {
    await databases.updateDocument(
        databaseId: appDatabase,
        collectionId: matchmakingCollection,
        documentId: data.$id,
        data: {'is_locked': true});
  }
}

Future<void> scheduleRoomForDeletion(int roomID) async {
  //Rooms are deleted at 03:00 in the night by an appwrite function
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: matchmakingCollection,
      queries: [
        Query.equal('room_id', roomID),
      ]);
  for (var data in response.documents) {
    await databases.updateDocument(
        databaseId: appDatabase,
        collectionId: matchmakingCollection,
        documentId: data.$id,
        data: {'is_finished': true});
  }
}

Future<void> deleteGameData(int roomID) async {
  //This function might get a bit long, but it's Single Responsibility and these processes probably ever won't run on themselves
  //UPDATE: This function is deprecated but might come in helpful for further development
  final reportedAssets = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: disapprovedMediaCollection,
      queries: [Query.equal("room_id", roomID)]);
  for (var asset in reportedAssets.documents) {
    try {
      await databases.deleteDocument(
          databaseId: appDatabase,
          collectionId: disapprovedMediaCollection,
          documentId: asset.$id);
    } catch (e) {
      //Only verbose, cause this probably just means another user has deleted this already
      logger.v(e);
    }
  }

  final matchmakingData = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: matchmakingCollection,
      queries: [Query.equal("room_id", roomID)]);
  for (var data in matchmakingData.documents) {
    try {
      await databases.deleteDocument(
          databaseId: appDatabase,
          collectionId: matchmakingCollection,
          documentId: data.$id);
    } catch (e) {
      logger.v(e);
    }
  }

  final roomChallengeData = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: roomChallengesCollection,
      queries: [Query.equal("room_id", roomID)]);
  for (var data in roomChallengeData.documents) {
    try {
      await databases.deleteDocument(
          databaseId: appDatabase,
          collectionId: roomChallengesCollection,
          documentId: data.$id);
    } catch (e) {
      logger.v(e);
    }
  }

  final roomAssets = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: roomMediaCollection,
      queries: [Query.equal("room_id", roomID)]);
  for (var asset in roomAssets.documents) {
    try {
      await databases.deleteDocument(
          databaseId: appDatabase,
          collectionId: roomMediaCollection,
          documentId: asset.$id);
      deleteBucketFile(Uri.parse(asset.data["media_url"]));
    } catch (e) {
      logger.v(e);
    }
  }
}
