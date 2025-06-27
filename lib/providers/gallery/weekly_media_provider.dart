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

final weeklyMediaProvider = FutureProvider<List<AssetEntity>>((ref) async {
  final permission = await PhotoManager.requestPermissionExtend();
  if (!permission.isAuth) {
    throw Exception('Galeri erişim izni verilmedi.');
  }

  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));

  final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
    type: RequestType.image,
    filterOption: FilterOptionGroup(
      orders: [
        const OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
      createTimeCond: DateTimeCond(
        min: sevenDaysAgo,
        max: now,
      ),
    ),
  );

  List<AssetEntity> recentImages = [];
  for (final album in albums) {
    final count = await album.assetCountAsync;
    if (count == 0) continue;
    final images = await album.getAssetListRange(start: 0, end: count);
    for (final image in images) {
      if (image.type == AssetType.image) {
        try {
          final file = await image.originFile;
          if (file == null || !(await file.exists())) {
            continue;
          }
          recentImages.add(image);
        } catch (_) {
          continue;
        }
      }
    }
  }
  // Benzersizleştir (id'ye göre)
  final uniqueAssets = <String, AssetEntity>{};
  for (final asset in recentImages) {
    uniqueAssets[asset.id] = asset;
  }
  return uniqueAssets.values.toList();
});
