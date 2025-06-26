import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'monthly_complete_helper.dart';

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
    return FutureBuilder<List<bool>>(
      future: Future.wait([
        MonthlyCompleteHelper.isListCompleted(photoList),
        MonthlyCompleteHelper.isListPending(photoList),
      ]),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data?[0] ?? false;
        final isPending = snapshot.data?[1] ?? false;
        final showCheck = isCompleted || isPending;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: height * 0.01),
            GestureDetector(
              onTap: () async {
                if (isCompleted) return;
                await ref
                    .read(swipeImagesProvider.notifier)
                    .setImagesFiltered(photoList);
                final filteredList = ref.read(swipeImagesProvider);
                final initialIndex = isPending ? filteredList.length : 0;
                ref.read(swipeCurrentIndexProvider.notifier).state =
                    initialIndex;
                ref.read(swipePendingDeleteProvider.notifier).clear();
                context.push(
                  '/swipe',
                  extra: {
                    'mediaList': filteredList,
                    'initialIndex': initialIndex,
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
                      if (showCheck) ...[
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
