import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:swipewipe/views/swipe/swipe_image_view.dart';

class SwipeImagesNotifier extends StateNotifier<List<AssetEntity>> {
  SwipeImagesNotifier() : super([]);

  void setImages(List<AssetEntity> images) {
    state = images;
  }

  Future<void> setImagesFiltered(List<AssetEntity> images) async {
    final filtered = <AssetEntity>[];
    for (final asset in images) {
      try {
        final file = await asset.originFile;
        if (file != null && await file.exists()) {
          filtered.add(asset);
        }
      } catch (e) {
        // PlatformException veya diğer hatalar: asset'i ekleme, devam et
        continue;
      }
    }
    state = filtered;
  }

  void removeAt(int index) {
    if (index < state.length) {
      state = [...state]..removeAt(index);
    }
  }
}

class PendingDeleteNotifier extends StateNotifier<List<AssetEntity>> {
  PendingDeleteNotifier() : super([]);

  void add(AssetEntity asset) {
    state = [...state, asset];
  }

  void clear() {
    state = [];
  }
}

class UserGalleryStats {
  final int deletedCount;
  final int savedCount;
  final int deletedTotalBytes;

  UserGalleryStats({
    required this.deletedCount,
    required this.savedCount,
    required this.deletedTotalBytes,
  });

  UserGalleryStats copyWith({
    int? deletedCount,
    int? savedCount,
    int? deletedTotalBytes,
  }) {
    return UserGalleryStats(
      deletedCount: deletedCount ?? this.deletedCount,
      savedCount: savedCount ?? this.savedCount,
      deletedTotalBytes: deletedTotalBytes ?? this.deletedTotalBytes,
    );
  }
}

class UserGalleryStatsNotifier extends AsyncNotifier<UserGalleryStats> {
  static const _deletedCountKey = 'deletedCount';
  static const _savedCountKey = 'savedCount';
  static const _deletedTotalBytesKey = 'deletedTotalBytes';

  @override
  Future<UserGalleryStats> build() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedCount = prefs.getInt(_deletedCountKey) ?? 0;
    final savedCount = prefs.getInt(_savedCountKey) ?? 0;
    final deletedTotalBytes = prefs.getInt(_deletedTotalBytesKey) ?? 0;
    return UserGalleryStats(
      deletedCount: deletedCount,
      savedCount: savedCount,
      deletedTotalBytes: deletedTotalBytes,
    );
  }

  Future<void> addDeleted(int bytes) async {
    final current = state.valueOrNull ??
        UserGalleryStats(deletedCount: 0, savedCount: 0, deletedTotalBytes: 0);
    final newState = current.copyWith(
      deletedCount: current.deletedCount + 1,
      deletedTotalBytes: current.deletedTotalBytes + bytes,
    );
    state = AsyncData(newState);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_deletedCountKey, newState.deletedCount);
    await prefs.setInt(_deletedTotalBytesKey, newState.deletedTotalBytes);
  }

  Future<void> addSaved() async {
    final current = state.valueOrNull ??
        UserGalleryStats(deletedCount: 0, savedCount: 0, deletedTotalBytes: 0);
    final newState = current.copyWith(savedCount: current.savedCount + 1);
    state = AsyncData(newState);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_savedCountKey, newState.savedCount);
  }
}

class DeleteMapNotifier extends StateNotifier<Map<String, Set<AssetEntity>>> {
  DeleteMapNotifier() : super({});

  void add(String listKey, AssetEntity entity) {
    final current = state[listKey] ?? <AssetEntity>{};
    state = {
      ...state,
      listKey: {...current, entity},
    };
  }

  void remove(String listKey, AssetEntity entity) {
    final current = state[listKey] ?? <AssetEntity>{};
    current.remove(entity);
    state = {
      ...state,
      listKey: {...current},
    };
  }

  void clear(String listKey) {
    state = {
      ...state,
      listKey: <AssetEntity>{},
    };
  }

  Set<AssetEntity> getList(String listKey) => state[listKey] ?? <AssetEntity>{};
}

final swipeImagesProvider =
    StateNotifierProvider<SwipeImagesNotifier, List<AssetEntity>>((ref) {
  return SwipeImagesNotifier();
});

final swipeCurrentIndexProvider = StateProvider<int>((ref) => 0);

final swipePendingDeleteProvider =
    StateNotifierProvider<PendingDeleteNotifier, List<AssetEntity>>((ref) {
  return PendingDeleteNotifier();
});

final userGalleryStatsProvider =
    AsyncNotifierProvider<UserGalleryStatsNotifier, UserGalleryStats>(
        UserGalleryStatsNotifier.new);

final deleteMapProvider =
    StateNotifierProvider<DeleteMapNotifier, Map<String, Set<AssetEntity>>>(
  (ref) => DeleteMapNotifier(),
);

final selectedDeleteProvider =
    StateProvider.family<Set<String>, String>((ref, listKey) => <String>{});

final swipeDirectionProvider = StateProvider<SwipDirection?>((ref) => null);
final isDraggingProvider = StateProvider<bool>((ref) => false);
final dragOffsetProvider = StateProvider<Offset>((ref) => Offset.zero);
