import 'package:appwrite/appwrite.dart';
import 'package:appwrite_hackathon_2024/classes/Submission.dart';
import 'package:appwrite_hackathon_2024/enums/appwrite.dart';

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
  return unsortedSubmissions;
}
