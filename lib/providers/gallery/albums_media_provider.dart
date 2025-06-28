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
    print('AlbumsNotifier: Constructor called.');
    _loadAlbums();
  }

  @override
  void dispose() {
    print('AlbumsNotifier: Disposed.');
    super.dispose();
  }

  Future<void> _loadAlbums() async {
    print('AlbumsNotifier: _loadAlbums called.');
    if (state.albums.isNotEmpty && !state.isLoading) {
      print('AlbumsNotifier: Albums already loaded and not loading, returning.');
      return;
    }

    state = state.copyWith(isLoading: true);
    print('AlbumsNotifier: Setting isLoading to true.');

    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        print('AlbumsNotifier: Permission not granted.');
        state = state.copyWith(isLoading: false);
        return;
      }

      // Fetch all albums (both image and video) in one go
      final albums = await PhotoManager.getAssetPathList(type: RequestType.common, hasAll: true);
      print('AlbumsNotifier: Fetched ${albums.length} raw albums.');

      final nonEmptyAlbums = <AssetPathEntity>[];
      for (final album in albums) {
        // 'Recents' (or 'All Photos') album is usually identified by isAll property
        if (album.isAll || album.name == 'Recently Added' || album.name == 'Recently Saved') {
          continue; // Skip this album
        }
        final count = await album.assetCountAsync;
        if (count > 0) {
          nonEmptyAlbums.add(album);
        }
      }
      print('AlbumsNotifier: Found ${nonEmptyAlbums.length} non-empty albums.');

      state = state.copyWith(albums: nonEmptyAlbums, isLoading: false);
      print('AlbumsNotifier: Albums loaded successfully. isLoading set to false.');
    } catch (e, stack) {
      print('''AlbumsNotifier: Error loading albums: $e
$stack''');
      state = state.copyWith(isLoading: false);
    }
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
  ref.keepAlive(); // Provider'ın durumunu bellekte tut
  return AlbumsNotifier();
});
