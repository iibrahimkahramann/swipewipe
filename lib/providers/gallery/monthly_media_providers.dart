import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:intl/intl.dart';

final monthlyMediaProvider =
    FutureProvider<Map<String, List<AssetEntity>>>((ref) async {
  final permission = await PhotoManager.requestPermissionExtend();
  if (!permission.isAuth) return {};

  final albums = await PhotoManager.getAssetPathList(
    onlyAll: true,
    type: RequestType.image,
  );

  final mediaList = await albums.first.getAssetListPaged(page: 0, size: 1000);

  final Map<String, List<AssetEntity>> grouped = {};

  for (var media in mediaList) {
    final date = media.createDateTime;
    final key = DateFormat('MMMM yyyy').format(date);
    grouped.putIfAbsent(key, () => []).add(media);
  }

  return grouped;
});
