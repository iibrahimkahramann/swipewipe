import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/bar/appbar.dart';
import 'package:swipewipe/config/bar/navbar.dart';
import 'package:swipewipe/providers/gallery/albums_media_provider.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/components/organize/albums_container_component.dart';

class AlbumsView extends ConsumerWidget {
  const AlbumsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('AlbumsView: build called.');
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final albumsState = ref.watch(albumsProvider);

    print('AlbumsView: albumsState.isLoading: ${albumsState.isLoading}');
    print('AlbumsView: albumsState.albums.isNotEmpty: ${albumsState.albums.isNotEmpty}');

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: albumsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : albumsState.albums.isEmpty
                      ? Center(child: Text("No albums found".tr()))
                      : ListView(
                          children: [
                            Text(
                              'Albums'.tr(),
                              style: CustomTheme.textTheme(context).bodyMedium,
                            ),
                            SizedBox(height: height * 0.0002),
                            ...albumsState.albums.map((album) {
                              return AlbumListItem(key: ValueKey(album.id), album: album);
                            }).toList(),
                          ],
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentLocation: '/albums'),
    );
  }
}

class AlbumListItem extends ConsumerStatefulWidget {
  final AssetPathEntity album;

  const AlbumListItem({super.key, required this.album});

  @override
  ConsumerState<AlbumListItem> createState() => _AlbumListItemState();
}

class _AlbumListItemState extends ConsumerState<AlbumListItem> {
  int _assetCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAssetCount();
  }

  Future<void> _getAssetCount() async {
    final count = await widget.album.assetCountAsync;
    if (mounted) {
      setState(() {
        _assetCount = count;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return const SizedBox.shrink(); // Don't build anything while counting assets
    }

   
    if (_assetCount == 0) {
      return AlbumsContainerComponent(
        height: height,
        width: width,
        title: 'Albums',
        albumsTitle: widget.album.name,
        albumsLeght: '0',
        photoList: [],
      );
    }

    // Lazily load 
    final albumsState = ref.watch(albumsProvider);
    final thumbnail = albumsState.thumbnails[widget.album.id];
    if (thumbnail == null && _assetCount > 0) {
      Future.microtask(() {
        if (mounted) {
          ref.read(albumsProvider.notifier).loadAlbumThumbnail(widget.album);
        }
      });
    }

    
    return FutureBuilder<List<AssetEntity>>(
      future: widget.album.getAssetListRange(start: 0, end: _assetCount),
      builder: (context, snapshot) {
        return AlbumsContainerComponent(
          height: height,
          width: width,
          title: 'Albums',
          albumsTitle: widget.album.name,
          albumsLeght: _assetCount.toString(),
          
          photoList: snapshot.data ?? [],
        );
      },
    );
  }
}
