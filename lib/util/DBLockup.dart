import 'package:appwrite/appwrite.dart';
import 'package:appwrite_hackathon_2024/enums/appwrite.dart';

Future<String> submissionToUsername(String submissionID) async {
  final mediaLookup = await databases.getDocument(
      databaseId: appDatabase,
      collectionId: roomMediaCollection,
      documentId: submissionID);
  String userEmail = mediaLookup.data['user_email'];
  final matchmakingLookup = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: matchmakingCollection,
      queries: [
        Query.equal('user_email', userEmail),
      ]);
  return matchmakingLookup.documents.first.data['user_name'];
}

Future<int> userAmountInRoom(int roomID) async {
  final matchmakingLookup = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: matchmakingCollection,
      queries: [
        Query.equal('room_id', roomID),
      ]);
  return matchmakingLookup.total;
}
