import 'package:appwrite/appwrite.dart';
import 'package:appwrite_hackathon_2024/classes/Submission.dart';
import 'package:appwrite_hackathon_2024/enums/appwrite.dart';

import '../../../main.dart';

Future<List<Submission>> getResults(int roomID) async {
  final results = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: roomMediaCollection,
      queries: [Query.equal("room_id", roomID)]);
  List<Submission> submissions = [];
  results.documents.forEach((e) {
    submissions.add(Submission(e.$id, Uri.parse(e.data['media_url']),
        DateTime.parse(e.$createdAt), roomID));
  });
  return await _sortSubmissionsByTime(submissions);
}

Future<List<Submission>> _sortSubmissionsByTime(
    List<Submission> unsortedSubmissions) async {
  unsortedSubmissions
      .sort((a, b) => b.submissionTime.compareTo(a.submissionTime));
  return unsortedSubmissions.reversed.toList();
}

Future<List<Map<String, dynamic>>> getLinkedUsersToVideo(int roomID) async {
  final participants = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: matchmakingCollection,
      queries: [Query.equal("room_id", roomID)]);
  List<Map<String, dynamic>> linkedSubmissions = [];
  for (var element in participants.documents) {
    final submissionByUser = await databases.listDocuments(
        databaseId: appDatabase,
        collectionId: roomMediaCollection,
        queries: [
          Query.equal("room_id", roomID),
          Query.equal('user_email', element.data['user_email'])
        ]);
    Submission submissionObjectByUser = Submission(
        submissionByUser.documents.first.$id,
        Uri.parse(submissionByUser.documents.first.data['media_url']),
        DateTime.parse(submissionByUser.documents.first.$createdAt),
        roomID);
    linkedSubmissions.add({
      "userName": element.data['user_name'],
      "submission": submissionObjectByUser
    });
  }
  linkedSubmissions.sort((a, b) => b['submission']!
      .submissionTime
      .compareTo(a['submission']!.submissionTime));
  return linkedSubmissions;
}
