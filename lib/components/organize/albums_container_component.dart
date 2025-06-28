import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'monthly_complete_helper.dart';
import 'swipe_complete_button.dart';
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
    // Her build'de durumu güncelle
    _checkStatus();
    //final showCheck = _isCompleted || _isPending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: widget.height * 0.01),
        GestureDetector(
          onTap: () async {
            await _checkStatus(); // En güncel durumu kontrol et
            if (_isCompleted) {
              // Tamamlandıysa bottom sheet aç
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: CustomTheme.backgroundColor,
                builder: (context) {
                  final width = MediaQuery.of(context).size.width;
                  final height = MediaQuery.of(context).size.height;
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).dialogBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.07,
                        vertical: height * 0.03,
                      ),
                      constraints: BoxConstraints(
                        minHeight: height * 0.22,
                        maxHeight: height * 0.5,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: width * 0.13),
                          SizedBox(height: height * 0.02),
                          Text(
                            'Swipe List Completed'.tr(),
                            style: CustomTheme.textTheme(context).bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.02),
                          SizedBox(
                            width: double.infinity,
                            child: SwipeCompleteButton(
                              onPressed: () async {
                                await MonthlyCompleteHelper.clearPending(widget.photoList);
                                await MonthlyCompleteHelper.clearCompleted(widget.photoList); // Tamamlanma durumunu da sil
                                if (!mounted) return;
                                setState(() {
                                  _isCompleted = false;
                                  _isPending = false;
                                });
                                Navigator.of(context).pop();
                                // Swipe ekranını başlat
                                ref.read(swipeImagesProvider.notifier).setImagesLazy(widget.photoList);
                                final filteredList = ref.read(swipeImagesProvider);
                                ref.read(swipeCurrentIndexProvider.notifier).state = 0;
                                ref.read(swipePendingDeleteProvider.notifier).clear();
                                context.push(
                                  '/swipe',
                                  extra: {
                                    'mediaList': filteredList,
                                    'initialIndex': 0,
                                    'listKey': widget.albumsTitle,
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              return;
            }
            // Tamamlanmadıysa swipe ekranına git
            ref
                .read(swipeImagesProvider.notifier)
                .setImagesLazy(widget.photoList);
            if (!mounted) return; // Widget dispose edildiyse devam etme
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
                  else if (_isCompleted)
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
