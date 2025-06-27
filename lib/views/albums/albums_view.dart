import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipewipe/components/organize/albums_container_component.dart';
import 'package:swipewipe/config/bar/appbar.dart';
import 'package:swipewipe/config/bar/navbar.dart';
import 'package:swipewipe/providers/gallery/albums_media_provider.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

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

    final albumsWithPhotosAsync = ref.watch(albumsWithPhotosProvider);

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
            Text(
              'Albums'.tr(),
              style: CustomTheme.textTheme(context).bodyMedium,
            ),
            Expanded(
              child: albumsWithPhotosAsync.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                    child: Text("Error occurred".tr(args: [e.toString()]))),
                data: (albumsMap) {
                  if (albumsMap.isEmpty) {
                    return Center(child: Text("No albums found".tr()));
                  }
                  return ListView(
                    children: albumsMap.entries.map((entry) {
                      final albumName = entry.key;
                      final photoList = entry.value;
                      return AlbumsContainerComponent(
                        height: height,
                        width: width,
                        title: 'Albums',
                        albumsTitle: albumName,
                        albumsLeght: photoList.length.toString(),
                        photoList: photoList,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentLocation: '/albums'),
    );
  }
}
