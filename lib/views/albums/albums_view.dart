import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/components/organize/albums_container_component.dart';
import 'package:swipewipe/config/bar/appbar.dart';
import 'package:swipewipe/config/bar/navbar.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/gallery/albums_media_provider.dart';

class AlbumsView extends ConsumerStatefulWidget {
  const AlbumsView({super.key});

  @override
  ConsumerState<AlbumsView> createState() => _AlbumsViewState();
}

class _AlbumsViewState extends ConsumerState<AlbumsView> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final albumListAsync = ref.watch(albumListProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: height * 0.02,
        ),
        child: albumListAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Hata: $e")),
          data: (albums) {
            if (albums.isEmpty) {
              return Center(
                child: Text(
                  "You cannot use without gallery permission".tr(),
                  style: CustomTheme.textTheme(context).bodySmall,
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              itemCount: albums.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(),
                    child: Text('Albums'.tr(),
                        style: CustomTheme.textTheme(context).bodyMedium),
                  );
                }

                final album = albums[index - 1];
                return FutureBuilder<List<AssetEntity>>(
                  future: album.getAssetListPaged(page: 0, size: 100),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final photoList = snapshot.data!;

                    return AlbumsContainerComponent(
                      height: height,
                      width: width,
                      title: 'Albums'.tr(),
                      albumsTitle: album.name,
                      albumsLeght: photoList.length.toString(),
                      photoList: photoList,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentLocation: '/albums'),
    );
  }
}
