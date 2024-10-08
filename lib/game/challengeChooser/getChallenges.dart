import '../../enums/appwrite.dart';

Future<List<String>> getChallenges({bool isOutdoor = true}) async {
  final response = await databases.listDocuments(
    databaseId: appDatabase,
    collectionId: roomChallengesCollection,
    queries: [

    ]
  )
}