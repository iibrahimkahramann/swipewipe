import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

// State class for weekly media
class WeeklyMediaState {
  final List<AssetEntity> assets;
  final Map<String, Uint8List> thumbnails;
  final bool isLoading;

  WeeklyMediaState({
    this.assets = const [],
    this.thumbnails = const {},
    this.isLoading = true,
  });

  WeeklyMediaState copyWith({
    List<AssetEntity>? assets,
    Map<String, Uint8List>? thumbnails,
    bool? isLoading,
  }) {
    return WeeklyMediaState(
      assets: assets ?? this.assets,
      thumbnails: thumbnails ?? this.thumbnails,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// StateNotifier for weekly media
class WeeklyMediaNotifier extends StateNotifier<WeeklyMediaState> {
  WeeklyMediaNotifier() : super(WeeklyMediaState()) {
    _loadWeeklyMediaMetadata();
  }

  Future<void> _loadWeeklyMediaMetadata() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // This directly gets a special "album" that contains only assets matching the filter.
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
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

    if (paths.isEmpty) {
      state = state.copyWith(isLoading: false, assets: []);
      return;
    }

    // The first path entity is the virtual album containing our filtered assets.
    final AssetPathEntity mainPath = paths.first;
    final List<AssetEntity> recentAssets = await mainPath.getAssetListRange(
      start: 0,
      end: await mainPath.assetCountAsync,
    );

    state = state.copyWith(assets: recentAssets, isLoading: false);
  }

  Future<void> loadThumbnail(AssetEntity asset) async {
    if (state.thumbnails.containsKey(asset.id)) {
      return;
    }

    final thumbData = await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));

    if (thumbData != null) {
      final newThumbnails = Map<String, Uint8List>.from(state.thumbnails);
      newThumbnails[asset.id] = thumbData;
      state = state.copyWith(thumbnails: newThumbnails);
    }
  }
}

// The provider for weekly media
final weeklyMediaProvider =
    StateNotifierProvider<WeeklyMediaNotifier, WeeklyMediaState>((ref) {
  return WeeklyMediaNotifier();
});
