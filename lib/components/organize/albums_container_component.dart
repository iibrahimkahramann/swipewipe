import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'monthly_complete_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumsContainerComponent extends ConsumerStatefulWidget {
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
  ConsumerState<AlbumsContainerComponent> createState() =>
      _AlbumsContainerComponentState();
}

class _AlbumsContainerComponentState
    extends ConsumerState<AlbumsContainerComponent> {
  bool _isCompleted = false;
  bool _isPending = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final isCompleted = await MonthlyCompleteHelper.isListCompleted(widget.photoList);
    final isPending = await MonthlyCompleteHelper.isListPending(widget.photoList);
    if (mounted) {
      setState(() {
        _isCompleted = isCompleted;
        _isPending = isPending;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showCheck = _isCompleted || _isPending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: widget.height * 0.01),
        GestureDetector(
          onTap: () async {
            if (_isCompleted) return;
            await ref
                .read(swipeImagesProvider.notifier)
                .setImagesFiltered(widget.photoList);
            final filteredList = ref.read(swipeImagesProvider);
            final prefs = await SharedPreferences.getInstance();
            final savedIndex =
                prefs.getInt('swipe_index_${widget.albumsTitle}') ?? 0;
            final initialIndex = _isPending
                ? filteredList.length
                : (savedIndex < filteredList.length ? savedIndex : 0);
            ref.read(swipeCurrentIndexProvider.notifier).state = initialIndex;
            ref.read(swipePendingDeleteProvider.notifier).clear();
            context.push(
              '/swipe',
              extra: {
                'mediaList': filteredList,
                'initialIndex': initialIndex,
                'listKey': widget.albumsTitle,
              },
            );
          },
          child: Container(
            width: widget.width,
            height: widget.height * 0.07,
            decoration: BoxDecoration(
              color: CustomTheme.secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.width * 0.04),
              child: Row(
                children: [
                  Text(
                    widget.albumsTitle,
                    style: CustomTheme.textTheme(context).bodySmall,
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (showCheck)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  else
                    Text(
                      widget.albumsLeght,
                      style: CustomTheme.textTheme(context).bodySmall,
                    ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
