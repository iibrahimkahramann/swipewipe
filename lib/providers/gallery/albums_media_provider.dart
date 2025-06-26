import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

final albumsWithPhotosProvider =
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

  Map<String, List<AssetEntity>> albumPhotos = {};
  for (final album in albums) {
    final count = await album.assetCountAsync;
    if (count == 0) continue;
    final images = await album.getAssetListRange(start: 0, end: count);
    final uniqueAssets = <String, AssetEntity>{};
    for (final image in images) {
      uniqueAssets[image.id] = image;
    }
    final filteredImages = <AssetEntity>[];
    for (final asset in uniqueAssets.values) {
      try {
        final file = await asset.originFile;
        if (file == null || !(await file.exists())) {
          continue;
        }
        filteredImages.add(asset);
      } catch (_) {
        continue;
      }
    }
    albumPhotos[album.name] = filteredImages;
  }
  return albumPhotos;
});
