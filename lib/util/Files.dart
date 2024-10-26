import 'package:http/http.dart' as http;

import '../main.dart';

Future<bool> assetIsVideo(Uri uri) async {
  try {
    final response = await http.head(uri);
    if (response.headers.containsKey('content-type')) {
      final contentType = response.headers['content-type'] ?? '';
      return contentType.startsWith('video/');
    }
  } catch (e) {
    logger.e("Error occurred while fetching headers: $e");
  }
  return false;
}
