import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../../../enums/appwrite.dart';
import '../../../../enums/gameConfig.dart';
import '../../../final/management/clean.dart';

Future<void> disapproveAsset(User user, Uri asset, int roomID) async {
  await databases.createDocument(
    databaseId: appDatabase,
    collectionId: disapprovedMediaCollection,
    documentId: ID.unique(),
    data: {
      'reporter_email': user.email,
      'reported_medium': asset.toString(),
      'room_id': roomID
    },
  );
  if (await _countDisapprovalsForAsset(asset) >= assetDisapprovalThreshold) {
    await cleanUpDisapprovals(asset);
  }
}

Future<int> _countDisapprovalsForAsset(Uri asset) async {
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: disapprovedMediaCollection,
      queries: [Query.equal("reported_medium", asset.toString())]);
  return response.total;
}

Future<void> cleanUpDisapprovals(Uri asset) async {
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: disapprovedMediaCollection,
      queries: [Query.equal("reported_medium", asset.toString())]);
  for (var document in response.documents) {
    await databases.deleteDocument(
        databaseId: appDatabase,
        collectionId: disapprovedMediaCollection,
        documentId: document.$id);
  }
  final response2 = await databases.listDocuments(
    collectionId: roomMediaCollection,
    databaseId: appDatabase,
    queries: [Query.equal("media_url", asset.toString())],
  );
  await databases.deleteDocument(
      databaseId: appDatabase,
      collectionId: roomMediaCollection,
      documentId: response2.documents[0].$id);
  await deleteBucketFile(asset);
}
