import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

class SwipeImagesNotifier extends StateNotifier<List<AssetEntity>> {
  SwipeImagesNotifier() : super([]);

  void setImages(List<AssetEntity> images) {
    state = images;
  }

  void removeAt(int index) {
    if (index < state.length) {
      state = [...state]..removeAt(index);
    }
  }
}

final swipeImagesProvider =
    StateNotifierProvider<SwipeImagesNotifier, List<AssetEntity>>((ref) {
  return SwipeImagesNotifier();
});

final swipeCurrentIndexProvider = StateProvider<int>((ref) {
  return 0; // Başlangıç indeksi
});
