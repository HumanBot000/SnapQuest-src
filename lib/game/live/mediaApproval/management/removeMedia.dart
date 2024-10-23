import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import '../../../../enums/appwrite.dart';
import '../../../../enums/gameConfig.dart';

Future<void> disapproveAsset(User user, Uri asset) async {
  await databases.createDocument(
    databaseId: appDatabase,
    collectionId: disapprovedMediaBucket,
    documentId: ID.unique(),
    data: {
      'reporter_email': user.email,
      'reported_medium': asset.toString(),
    },
  );
  if (await _countDisapprovalsForAsset(asset) >= assetDisapprovalThreshold) {
    await cleanUpDisapprovals(asset);
  }
}

Future<int> _countDisapprovalsForAsset(Uri asset) async {
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: disapprovedMediaBucket,
      queries: [Query.equal("reported_medium", asset.toString())]);
  return response.total;
}

Future<void> cleanUpDisapprovals(Uri asset) async {
  final response = await databases.listDocuments(
      databaseId: appDatabase,
      collectionId: disapprovedMediaBucket,
      queries: [Query.equal("reported_medium", asset.toString())]);
  for (var document in response.documents) {
    //todo Also clean this up after the game
    await databases.deleteDocument(
        databaseId: appDatabase,
        collectionId: disapprovedMediaBucket,
        documentId: document.$id);
  }
  final response2 = await databases.listDocuments(
    collectionId: gameMediaBucket,
    databaseId: appDatabase,
    queries: [Query.equal("media_url", asset.toString())],
  );
  await databases.deleteDocument(
      databaseId: appDatabase,
      collectionId: gameMediaBucket,
      documentId: response2.documents[0].$id);
}
