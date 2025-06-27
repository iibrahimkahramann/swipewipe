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

  final List<AssetPathEntity> videoAlbums = await PhotoManager.getAssetPathList(
    type: RequestType.video,
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
      if (image.type == AssetType.image) {
        uniqueAssets[image.id] = image;
      }
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

  for (final album in videoAlbums) {
    if (album.name.toLowerCase() == 'videos') {
      final count = await album.assetCountAsync;
      if (count == 0) continue;
      final videos = await album.getAssetListRange(start: 0, end: count);
      final uniqueVideos = <String, AssetEntity>{};
      for (final video in videos) {
        if (video.type == AssetType.video) {
          uniqueVideos[video.id] = video;
        }
      }
      final filteredVideos = <AssetEntity>[];
      for (final asset in uniqueVideos.values) {
        try {
          final file = await asset.originFile;
          if (file == null || !(await file.exists())) {
            continue;
          }
          filteredVideos.add(asset);
        } catch (_) {
          continue;
        }
      }
      albumPhotos[album.name] = filteredVideos;
    }
  }
  return albumPhotos;
});
