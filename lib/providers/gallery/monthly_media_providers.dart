import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:intl/intl.dart';

// State class to hold our data, loading status, and thumbnail cache
class MonthlyMediaState {
  final Map<String, List<AssetEntity>> monthlyGroups;
  final Map<String, Uint8List> thumbnails;
  final bool isLoading;

  MonthlyMediaState({
    this.monthlyGroups = const {},
    this.thumbnails = const {},
    this.isLoading = true,
  });

  MonthlyMediaState copyWith({
    Map<String, List<AssetEntity>>? monthlyGroups,
    Map<String, Uint8List>? thumbnails,
    bool? isLoading,
  }) {
    return MonthlyMediaState(
      monthlyGroups: monthlyGroups ?? this.monthlyGroups,
      thumbnails: thumbnails ?? this.thumbnails,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// StateNotifier to manage fetching media and thumbnails
class MonthlyMediaNotifier extends StateNotifier<MonthlyMediaState> {
  MonthlyMediaNotifier() : super(MonthlyMediaState()) {
    _loadMediaMetadata();
  }

  Future<void> _loadMediaMetadata() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      state = state.copyWith(isLoading: false);
      // Handle permission denied case if needed
      return;
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    // Fetch all assets from the primary album without expensive checks
    final AssetPathEntity mainAlbum = albums.first;
    final List<AssetEntity> allAssets = await mainAlbum.getAssetListRange(
      start: 0,
      end: await mainAlbum.assetCountAsync,
    );

    // Group assets by month using their metadata
    Map<DateTime, List<AssetEntity>> tempGroups = {};
    for (final asset in allAssets) {
      final date = asset.createDateTime;
      final key = DateTime(date.year, date.month);
      tempGroups.putIfAbsent(key, () => []).add(asset);
    }

    // Sort groups chronologically
    final sortedKeys = tempGroups.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedMonthlyGroups = <String, List<AssetEntity>>{};
    for (final key in sortedKeys) {
      final keyStr = DateFormat('MMMM yyyy').format(key);
      sortedMonthlyGroups[keyStr] = tempGroups[key]!;
    }

    state = state.copyWith(
      monthlyGroups: sortedMonthlyGroups,
      isLoading: false,
    );
  }

  // Fetch a thumbnail for a specific asset and cache it
  Future<void> loadThumbnail(AssetEntity asset) async {
    // If already cached or asset is not an image, do nothing.
    if (state.thumbnails.containsKey(asset.id) || asset.type != AssetType.image) {
      return;
    }

    // Fetch thumbnail data
    final thumbData = await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));

    if (thumbData != null) {
      // Create a new map and add the new thumbnail
      final newThumbnails = Map<String, Uint8List>.from(state.thumbnails);
      newThumbnails[asset.id] = thumbData;
      
      // Update state with the new thumbnail map
      state = state.copyWith(thumbnails: newThumbnails);
    }
  }
}

// The provider that exposes the MonthlyMediaNotifier
final monthlyMediaProvider =
    StateNotifierProvider<MonthlyMediaNotifier, MonthlyMediaState>((ref) {
  return MonthlyMediaNotifier();
});
