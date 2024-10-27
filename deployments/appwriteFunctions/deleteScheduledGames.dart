import 'package:appwrite/appwrite.dart';
import 'package:appwrite_hackathon_2024/enums/appwrite.dart';
import 'package:appwrite_hackathon_2024/game/final/management/clean.dart';

Future<void> main() async {
  final games = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: matchmakingCollection,
      queries: [
        Query.equal('is_finished', true),
      ]);
  for (var game in games.documents) {
    deleteGameData(game.data['room_id']);
  }
}
