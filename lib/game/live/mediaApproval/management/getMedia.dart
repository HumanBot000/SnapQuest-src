import 'package:appwrite/appwrite.dart';

import '../../../../enums/appwrite.dart';

Future<List<Uri>> getMedia(int roomID) async {
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: roomMediaCollection,
      queries: [
        Query.equal('room_id', roomID),
      ]);
  return response.documents.map((e) => Uri.parse(e.data['media_url'])).toList();
}
