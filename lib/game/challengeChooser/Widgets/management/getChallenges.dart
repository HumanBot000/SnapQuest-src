import 'package:appwrite/appwrite.dart';
import 'package:SnapQuest/classes/Challenge.dart';
import '../../../../enums/appwrite.dart';

Future<List<Challenge>> getChallenges({bool isOutdoor = true}) async {
  List<Challenge> challenges = [];
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: challengesCollection,
      queries: [Query.equal('is_outdoor', isOutdoor)]);
  for (var challenge in response.documents) {
    var challengeData = challenge.data;
    challenges.add(Challenge(
      challenge.$id,
      challengeData['description_en'],
      challengeData['difficulty'],
      challengeData['is_outdoor'],
      challengeData['photo_allowed'],
      challengeData['video_allowed'],
    ));
  }
  return challenges;
}
