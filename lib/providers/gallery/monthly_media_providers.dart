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
    allAssets.addAll(images);
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

  // 3. Grupla
  Map<String, List<AssetEntity>> monthlyGroups = {};
  for (final asset in filteredAssets) {
    final date = asset.createDateTime;
    final key = DateFormat('MMMM yyyy').format(date);
    monthlyGroups.putIfAbsent(key, () => []).add(asset);
  }
  return monthlyGroups;
});
