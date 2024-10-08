import 'package:appwrite/appwrite.dart';
import 'package:appwrite_hackathon_2024/classes/Challenge.dart';
import '../../enums/appwrite.dart';

Future<List<Challenge>> getChallenges({bool isOutdoor = true}) async {
  List<Challenge> challenges = [];
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: roomChallengesCollection,
      queries: [Query.equal('	is_outdoor', isOutdoor)]);
  for (var challenge in response.documents) {
    var _challengeData = challenge.data;
    challenges.add(Challenge(
      challenge.$id,
      _challengeData['description_en'],
      _challengeData['difficulty'],
      _challengeData['is_outdoor'],
      _challengeData['photo_allowed'],
      _challengeData['video_allowed'],
    ));
  }
  return challenges;
}
