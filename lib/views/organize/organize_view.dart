import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swipewipe/components/organize/albums_container_component.dart';
import 'package:swipewipe/components/organize/organize_weekly_component.dart';
import 'package:swipewipe/config/bar/appbar.dart';
import 'package:swipewipe/config/bar/navbar.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/gallery/monthly_media_providers.dart';
import 'package:swipewipe/providers/gallery/weekly_media_provider.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrganizeView extends ConsumerStatefulWidget {
  const OrganizeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrganizeViewState();
}

class _OrganizeViewState extends ConsumerState<OrganizeView> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final weeklyMediaAsync = ref.watch(weeklyMediaProvider);
    final monthlyMediaAsync = ref.watch(monthlyMediaProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: height * 0.02,
        ),
        child: ListView(
          children: [
            weeklyMediaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Hata: $e'),
              data: (weeklyAssets) {
                if (weeklyAssets.isEmpty) {
                  return Center(child: Text("No photos in last 7 days"));
                }
                return OrganizeWeeklyComponent(
                  height: height,
                  width: width,
                  assets: weeklyAssets,
                  onTap: () async {
                    await ref
                        .read(swipeImagesProvider.notifier)
                        .setImagesFiltered(weeklyAssets);
                    final filteredList = ref.read(swipeImagesProvider);
                    final prefs = await SharedPreferences.getInstance();
                    final savedIndex = prefs.getInt('swipe_index_weekly') ?? 0;
                    final listKey = 'weekly';
                    ref.read(swipeCurrentIndexProvider.notifier).state =
                        savedIndex < filteredList.length ? savedIndex : 0;
                    ref.read(swipePendingDeleteProvider.notifier).clear();
                    context.push(
                      '/swipe',
                      extra: {
                        'mediaList': filteredList,
                        'initialIndex':
                            savedIndex < filteredList.length ? savedIndex : 0,
                        'listKey': listKey,
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: height * 0.01),
            Text(
              'By Month'.tr(),
              style: CustomTheme.textTheme(context).bodyMedium,
            ),
            monthlyMediaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
              data: (monthlyGroups) {
                if (monthlyGroups.isEmpty) {
                  return Center(child: Text("No photos found by month"));
                }
                final keys = monthlyGroups.keys.toList()
                  ..sort((a, b) => b.compareTo(a)); // Yeni ay en üstte
                return Column(
                  children: keys.map((monthTitle) {
                    final photos = monthlyGroups[monthTitle]!;
                    return AlbumsContainerComponent(
                      height: height,
                      width: width,
                      title: '',
                      albumsTitle: monthTitle,
                      albumsLeght: photos.length.toString(),
                      photoList: photos,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentLocation: '/organize'),
    );
  }
}
