import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'monthly_complete_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumsContainerComponent extends ConsumerWidget {
  final double height;
  final double width;
  final String title;
  final String albumsTitle;
  final String albumsLeght;
  final List<AssetEntity> photoList;

  const AlbumsContainerComponent({
    super.key,
    required this.height,
    required this.width,
    required this.title,
    required this.albumsTitle,
    required this.albumsLeght,
    required this.photoList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: MonthlyCompleteHelper.isListCompleted(photoList),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: height * 0.01),
            GestureDetector(
              onTap: () async {
                await ref
                    .read(swipeImagesProvider.notifier)
                    .setImagesFiltered(photoList);
                final filteredList = ref.read(swipeImagesProvider);
                final prefs = await SharedPreferences.getInstance();
                final savedIndex =
                    prefs.getInt('swipe_index_${albumsTitle}') ?? 0;
                final safeIndex =
                    savedIndex < filteredList.length ? savedIndex : 0;
                ref.read(swipeCurrentIndexProvider.notifier).state = safeIndex;
                ref.read(swipePendingDeleteProvider.notifier).clear();
                context.push(
                  '/swipe',
                  extra: {
                    'mediaList': filteredList,
                    'initialIndex': safeIndex,
                    'listKey': albumsTitle,
                  },
                );
              },
              child: Container(
                width: width,
                height: height * 0.07,
                decoration: BoxDecoration(
                  color: CustomTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  child: Row(
                    children: [
                      Text(
                        albumsTitle,
                        style: CustomTheme.textTheme(context).bodySmall,
                      ),
                      const Spacer(),
                      if (isCompleted) ...[
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                      ] else ...[
                        Text(
                          albumsLeght,
                          style: CustomTheme.textTheme(context).bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
