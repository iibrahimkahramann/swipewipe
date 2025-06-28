import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

final galleryCountProvider = FutureProvider<int>((ref) async {
  final albums = await PhotoManager.getAssetPathList(
    type: RequestType.image,
  );
  if (albums.isEmpty) return 0;
  return await albums.first.assetCountAsync;
}); 