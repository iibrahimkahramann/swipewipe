import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

class LocalImage {
  final String assetPath;
  LocalImage(this.assetPath);
}

final initialAssetList = Provider<List<AssetEntity>>((ref) => []);

final imageListProvider =
    StateNotifierProvider<ImageListNotifier, List<AssetEntity>>((ref) {
  final initialList = ref.watch(initialAssetList);
  return ImageListNotifier(initialList);
});

class ImageListNotifier extends StateNotifier<List<AssetEntity>> {
  ImageListNotifier(List<AssetEntity> initialList) : super(initialList);

  void removeImage(String id) {
    state = state.where((img) => img.id != id).toList();
  }

  void markAsSaved(String id) {
    // saklandı olarak işaretle (şimdilik silmiyoruz, sadece gösterimden çıkar)
    state = state.where((img) => img.id != id).toList();
  }
}
