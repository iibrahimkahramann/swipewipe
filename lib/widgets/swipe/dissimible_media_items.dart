import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/widgets/swipe/swipe_background_widget.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:swipewipe/widgets/swipe/media_preview.dart';

class DismissibleMediaItem extends ConsumerWidget {
  final AssetEntity media;
  final int index;
  final int fileSizeBytes;

  const DismissibleMediaItem({
    super.key,
    required this.media,
    required this.index,
    required this.fileSizeBytes,
  });

  Future<void> _onDismissed(
      BuildContext context, WidgetRef ref, DismissDirection direction) async {
    ref.read(swipeImagesProvider.notifier).removeAt(index);
    if (direction == DismissDirection.endToStart) {
      ref.read(globalDeleteProvider.notifier).add(media);
      await ref
          .read(userGalleryStatsProvider.notifier)
          .addDeleted(fileSizeBytes);
    } else if (direction == DismissDirection.startToEnd) {
      await ref.read(userGalleryStatsProvider.notifier).addSaved();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(media.id),
      direction: DismissDirection.horizontal,
      background: swipeBackground(
        color: Colors.green.shade600,
        icon: Icons.archive_outlined,
        label: "Keep".tr(),
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: swipeBackground(
        color: Colors.red.shade600,
        icon: Icons.delete_outline,
        label: "Delete".tr(),
        alignment: Alignment.centerRight,
      ),
      onDismissed: (direction) async =>
          await _onDismissed(context, ref, direction),
      child: MediaPreview(media: media),
    );
  }
}
