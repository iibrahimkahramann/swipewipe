import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/gallery/gallery_permission_provider.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:swipewipe/providers/gallery/total_gallery_size_provider.dart'; // Yeni import

class StatisticsCard extends ConsumerWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final stats = ref.watch(userGalleryStatsProvider);
    final mediaAsync = ref.watch(mediaProvider);
    final totalGallerySizeAsync = ref.watch(totalGallerySizeProvider); // Yeni

    return mediaAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading statistics'.tr()),
      data: (mediaList) {
        final totalPhotos = mediaList.length;
        final photosSaved = stats.value?.savedCount ?? 0;
        final photosDeleted = stats.value?.deletedCount ?? 0;
        final spaceSavedMB =
            ((stats.value?.deletedTotalBytes ?? 0) / 1024 / 1024);

        return totalGallerySizeAsync.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading total gallery size'.tr()),
          data: (totalSize) {
            final totalGallerySizeMB = totalSize / 1024 / 1024;
            final maxSpace = totalGallerySizeMB > 0 ? totalGallerySizeMB : 1.0;
            final progressValue = spaceSavedMB / maxSpace;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Your Statistics'.tr(),
                //   style: CustomTheme.textTheme(context).bodyMedium,
                // ),
                // SizedBox(height: height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSmallStatCard(context, 'Photos'.tr(), '$totalPhotos'),
                    _buildSmallStatCard(context, 'Saved'.tr(), '$photosSaved'),
                    _buildSmallStatCard(
                        context, 'Deleted'.tr(), '$photosDeleted'),
                  ],
                ),
                SizedBox(height: height * 0.01),
                Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: CustomTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Space Saved'.tr(),
                        style: CustomTheme.textTheme(context).bodySmall,
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        '${spaceSavedMB.toStringAsFixed(2)} MB',
                        style:
                            CustomTheme.textTheme(context).bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: height * 0.01),
                      LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor:
                            CustomTheme.primaryColor.withOpacity(0.3),
                        color: CustomTheme.regularColor,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSmallStatCard(BuildContext context, String title, String value) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.3,
      height: height * 0.08,
      decoration: BoxDecoration(
        color: CustomTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: CustomTheme.textTheme(context).bodySmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: height * 0.005),
          Text(
            value,
            style: CustomTheme.textTheme(context).bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
