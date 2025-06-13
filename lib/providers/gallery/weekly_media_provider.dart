import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

String getYearWeek(DateTime date) {
  final firstDayOfYear = DateTime(date.year, 1, 1);

  final firstWeekday = firstDayOfYear.weekday;

  final dayOfYear = date.difference(firstDayOfYear).inDays + 1;

  // ISO 8601 haftası hesaplama
  final weekNumber = ((dayOfYear + firstWeekday - 1) / 7).ceil();

  return '${date.year}-W$weekNumber';
}

final weeklyMediaProvider =
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
    final key = getYearWeek(date);
    grouped.putIfAbsent(key, () => []).add(media);
  }

  return grouped;
});
