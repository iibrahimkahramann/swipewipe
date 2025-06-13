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

    final groupedMonthlyMediaAsync = ref.watch(monthlyMediaProvider);
    final groupedWeeklyMediaAsync = ref.watch(weeklyMediaProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: height * 0.02,
        ),
        child: ListView(
          children: [
            // Haftalık
            groupedWeeklyMediaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Hata: $e'),
              data: (weeklyGrouped) {
                if (weeklyGrouped.isEmpty) return const SizedBox.shrink();

                final sortedKeys = weeklyGrouped.keys.toList()
                  ..sort((a, b) => b.compareTo(a));
                final latestWeekKey = sortedKeys.first;
                final weeklyAssets = weeklyGrouped[latestWeekKey]!;

                return OrganizeWeeklyComponent(
                  height: height,
                  width: width,
                  assets: weeklyAssets,
                  onTap: () {
                    context.push('/swipe', extra: {
                      'mediaList': weeklyAssets,
                      'initialIndex': 0,
                    });
                  },
                );
              },
            ),

            SizedBox(height: height * 0.02),

            Text(
              'By Month',
              style: CustomTheme.textTheme(context).bodyMedium,
            ),

            groupedMonthlyMediaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
              data: (groupedMonthlyMedia) {
                final keys = groupedMonthlyMedia.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return Column(
                  children: keys.map((monthTitle) {
                    final photos = groupedMonthlyMedia[monthTitle]!;

                    return AlbumsContainerComponent(
                      height: height,
                      width: width,
                      title: 'By Month',
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
