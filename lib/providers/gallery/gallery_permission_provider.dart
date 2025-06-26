import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

final mediaProvider = FutureProvider<List<AssetEntity>>((ref) async {
  final permission = await PhotoManager.requestPermissionExtend();

  if (!permission.isAuth) {
    return [];
  }

  final albums = await PhotoManager.getAssetPathList(
    onlyAll: true,
    type: RequestType.all,
  );

  final recentAlbum = albums.first;

  final count = await recentAlbum.assetCountAsync;
  final media = await recentAlbum.getAssetListRange(start: 0, end: count);
  return media;
});
