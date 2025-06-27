import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:intl/intl.dart';

final monthlyMediaProvider =
    FutureProvider<Map<String, List<AssetEntity>>>((ref) async {
  final permission = await PhotoManager.requestPermissionExtend();
  if (!permission.isAuth) {
    throw Exception('Galeri erişim izni verilmedi.');
  }

  final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
    type: RequestType.image,
    filterOption: FilterOptionGroup(
      orders: [
        const OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
    ),
  );

  // 1. Tüm assetleri topla
  final List<AssetEntity> allAssets = [];
  for (final album in albums) {
    final count = await album.assetCountAsync;
    if (count == 0) continue;
    final images = await album.getAssetListRange(start: 0, end: count);
    for (final asset in images) {
      if (asset.type == AssetType.image) {
        allAssets.add(asset);
      }
    }
  }

  // 2. Benzersizleştir (id'ye göre)
  final uniqueAssets = <String, AssetEntity>{};
  for (final asset in allAssets) {
    uniqueAssets[asset.id] = asset;
  }
  final filteredAssets = <AssetEntity>[];
  for (final asset in uniqueAssets.values) {
    try {
      final file = await asset.originFile;
      if (file == null || !(await file.exists())) continue;
      filteredAssets.add(asset);
    } catch (_) {
      continue;
    }
  }

  // 3. Grupla (DateTime anahtar ile)
  Map<DateTime, List<AssetEntity>> monthlyGroups = {};
  for (final asset in filteredAssets) {
    final date = asset.createDateTime;
    final key = DateTime(date.year, date.month);
    monthlyGroups.putIfAbsent(key, () => []).add(asset);
  }

  // Anahtarları (ayları) yeni aya en yakın olacak şekilde sırala
  final sortedKeys = monthlyGroups.keys.toList()
    ..sort((a, b) => b.compareTo(a)); // Yeni ay en üstte
  final sortedMonthlyGroups = <String, List<AssetEntity>>{};
  for (final key in sortedKeys) {
    final keyStr = DateFormat('MMMM yyyy').format(key);
    sortedMonthlyGroups[keyStr] = monthlyGroups[key]!;
  }
  return sortedMonthlyGroups;
});
