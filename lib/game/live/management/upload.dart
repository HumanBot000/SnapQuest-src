import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:appwrite_hackathon_2024/enums/appwrite.dart';
import '../../../userAuth/auth_service.dart';

final storage = Storage(client);

Future<String> uploadFile(String path, User user, int roomId) async {
  final file = await storage.createFile(
      bucketId: gameMediaBucket,
      fileId: ID.unique(),
      file: InputFile.fromPath(
          path: path,
          filename:
              '${user.name}-${roomId.toString()}.${path.split('/').last}'));
  return "https://cloud.appwrite.io/v1/storage/buckets/$gameMediaBucket/files/${file.$id}/view?project=$projectID";
}

Future<void> insertFileToDB(String imageURL, User user, int roomId) async {
  await databases.createDocument(
      databaseId: appDatabase,
      collectionId: roomMediaCollection,
      documentId: ID.unique(),
      data: {
        'media_url': imageURL,
        'user_email': user.email,
        'room_id': roomId
      });
}
