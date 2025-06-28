import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

// State for albums
class AlbumsState {
  final List<AssetPathEntity> albums;
  final Map<String, Uint8List> thumbnails; // Cache for album thumbnails
  final bool isLoading;

  AlbumsState({
    this.albums = const [],
    this.thumbnails = const {},
    this.isLoading = true,
  });

  AlbumsState copyWith({
    List<AssetPathEntity>? albums,
    Map<String, Uint8List>? thumbnails,
    bool? isLoading,
  }) {
    return AlbumsState(
      albums: albums ?? this.albums,
      thumbnails: thumbnails ?? this.thumbnails,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// StateNotifier for albums
class AlbumsNotifier extends StateNotifier<AlbumsState> {
  AlbumsNotifier() : super(AlbumsState()) {
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      state = state.copyWith(isLoading: false);
      return;
    }

    // Fetch all albums (both image and video) in one go
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common, // Fetches both image and video
      hasAll: true,
    );

    // Filter out empty albums
    final nonEmptyAlbums = <AssetPathEntity>[];
    for (final album in albums) {
      final count = await album.assetCountAsync;
      if (count > 0) {
        nonEmptyAlbums.add(album);
      }
    }

    state = state.copyWith(albums: nonEmptyAlbums, isLoading: false);
  }

  // Lazily load the thumbnail for a specific album
  Future<void> loadAlbumThumbnail(AssetPathEntity album) async {
    final count = await album.assetCountAsync;
    if (state.thumbnails.containsKey(album.id) || count == 0) {
      return;
    }

    // Get the very first asset of the album to use as a thumbnail
    final firstAsset = (await album.getAssetListRange(start: 0, end: 1)).first;

    final thumbData = await firstAsset.thumbnailDataWithSize(const ThumbnailSize(200, 200));

    if (thumbData != null) {
      final newThumbnails = Map<String, Uint8List>.from(state.thumbnails);
      newThumbnails[album.id] = thumbData;
      state = state.copyWith(thumbnails: newThumbnails);
    }
  }
}

// The provider for albums
final albumsProvider = StateNotifierProvider<AlbumsNotifier, AlbumsState>((ref) {
  return AlbumsNotifier();
});
