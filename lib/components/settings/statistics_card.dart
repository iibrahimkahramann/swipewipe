import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:swipewipe/providers/gallery/gallery_count_provider.dart';

class StatisticsCard extends ConsumerWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final stats = ref.watch(userGalleryStatsProvider);
    final galleryCountAsync = ref.watch(galleryCountProvider);

    return galleryCountAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading statistics'.tr()),
      data: (totalPhotos) {
        final photosSaved = stats.value?.savedCount ?? 0;
        final photosDeleted = stats.value?.deletedCount ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSmallStatCard(context, 'Photos'.tr(), '$totalPhotos'),
                _buildSmallStatCard(context, 'Saved'.tr(), '$photosSaved'),
                _buildSmallStatCard(context, 'Deleted'.tr(), '$photosDeleted'),
              ],
            ),
            
          ],
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
            style: CustomTheme.textTheme(context)
                .bodySmall
                ?.copyWith(fontSize: height * 0.015),
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
