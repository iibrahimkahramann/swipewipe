import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/gallery/weekly_media_provider.dart';

class OrganizeWeeklyComponent extends ConsumerWidget {
  const OrganizeWeeklyComponent({
    super.key,
    required this.height,
    required this.width,
    required this.onTap,
  });

  final double height;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyMediaState = ref.watch(weeklyMediaProvider);
    final assets = weeklyMediaState.assets;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly'.tr(),
            style: CustomTheme.textTheme(context).bodyMedium,
          ),
          SizedBox(
            height: height * 0.27,
            child: weeklyMediaState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    alignment: Alignment.center,
                    children: List.generate(assets.take(3).length, (index) {
                      final asset = assets[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          top: height * 0.01,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LazyWeeklyImage(asset: asset),
                        ),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}

class LazyWeeklyImage extends ConsumerWidget {
  final AssetEntity asset;

  const LazyWeeklyImage({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyMediaState = ref.watch(weeklyMediaProvider);
    final cachedThumbnail = weeklyMediaState.thumbnails[asset.id];

    if (cachedThumbnail != null) {
      return Image.memory(
        cachedThumbnail,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      Future.microtask(() {
        ref.read(weeklyMediaProvider.notifier).loadThumbnail(asset);
      });

      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      );
    }
  }
}
