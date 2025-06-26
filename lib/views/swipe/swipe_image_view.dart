import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:swipewipe/widgets/swipe/media_preview.dart';
import 'package:swipewipe/components/organize/swipe_complete_button.dart';
import 'package:swipewipe/components/organize/monthly_complete_helper.dart';
import 'package:swipewipe/widgets/swipe/delete_preview_page.dart';

enum SwipDirection { Left, Right }

final swipeIndexProvider =
    StateNotifierProvider.family<SwipeIndexNotifier, int, String>(
        (ref, listKey) {
  return SwipeIndexNotifier();
});

class SwipeIndexNotifier extends StateNotifier<int> {
  SwipeIndexNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }

  void increment() {
    state++;
  }
}

final listCompletedProvider =
    StateProvider.family<bool, String>((ref, listKey) => false);
final listPendingProvider =
    StateProvider.family<bool, String>((ref, listKey) => false);

class SwipeImageView extends ConsumerStatefulWidget {
  final String? listKey;
  final List<AssetEntity>? initialList;
  final int? initialIndex;

  const SwipeImageView(
      {super.key, this.listKey, this.initialList, this.initialIndex});

  @override
  ConsumerState<SwipeImageView> createState() => _SwipeImageViewState();
}

class _SwipeImageViewState extends ConsumerState<SwipeImageView>
    with SingleTickerProviderStateMixin {
  late List<AssetEntity> _localImages;

  late AnimationController _animationController;
  late Animation<Offset> _animation;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  SwipDirection? _swipeDirection;

  bool _isIndexReady = false;

  @override
  void initState() {
    super.initState();

    _localImages = widget.initialList ?? [];

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    final listKey = widget.listKey ?? 'default';
    // Provider'ları sıfırla (her listeye özel)
    Future.microtask(() {
      ref.read(listCompletedProvider(listKey).notifier).state = false;
      ref.read(listPendingProvider(listKey).notifier).state = false;
    });
    _checkListCompleted();
    _loadSavedIndex();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedIndex() async {
    int index = 0;
    final listKey = widget.listKey ?? 'default';
    if (widget.initialIndex != null) {
      index = widget.initialIndex!;
    } else if (widget.listKey != null) {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt('swipe_index_${widget.listKey}') ?? 0;
      index = savedIndex < _localImages.length ? savedIndex : 0;
    }
    Future.microtask(() {
      ref.read(swipeIndexProvider(listKey).notifier).setIndex(index);
    });
    if (mounted) {
      setState(() {
        _isIndexReady = true;
      });
    }
  }

  Future<void> _saveCurrentIndex(int index) async {
    if (widget.listKey != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('swipe_index_${widget.listKey}', index);
    }
  }

  void _onSwipeComplete(int index, SwipDirection direction) {
    if (index < 0 || index >= _localImages.length) return;

    final media = _localImages[index];
    final listKey = widget.listKey ?? 'default';

    if (direction == SwipDirection.Right) {
      ref.read(deleteMapProvider.notifier).add(listKey, media);
    } else if (direction == SwipDirection.Left) {
      ref.read(swipePendingDeleteProvider.notifier).add(media);
    }

    final newIndex = index + 1;
    ref.read(swipeIndexProvider(listKey).notifier).setIndex(newIndex);
    _saveCurrentIndex(newIndex);
  }

  void _onManualAction(SwipDirection direction, int currentIndex) {
    if (currentIndex >= _localImages.length) return;

    // Swipe animasyonunu başlat
    setState(() {
      _swipeDirection = direction;
      _isDragging = false;
      _dragOffset = Offset(direction == SwipDirection.Right ? 500 : -500, 0);
    });

    _animation = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward(from: 0).whenComplete(() {
      _onSwipeComplete(currentIndex, direction);
      setState(() {
        _dragOffset = Offset.zero;
        _swipeDirection = null;
      });
    });
  }

  void _animateCard(Offset target) {
    _animation = Tween<Offset>(begin: _dragOffset, end: target).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward(from: 0).whenComplete(() {
      setState(() {
        if (target == Offset.zero) {
          _dragOffset = Offset.zero;
          _swipeDirection = null;
        } else {
          final currentIndex =
              ref.read(swipeIndexProvider(widget.listKey ?? 'default'));
          if (_swipeDirection != null) {
            _onSwipeComplete(currentIndex, _swipeDirection!);
          }
          _dragOffset = Offset.zero;
          _swipeDirection = null;
        }
      });
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = Offset.zero;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details, int currentIndex) {
    setState(() {
      _isDragging = false;
    });

    final threshold = 100;

    if (_dragOffset.dx > threshold) {
      _swipeDirection = SwipDirection.Right;
      _animateCard(Offset(500, 0));
    } else if (_dragOffset.dx < -threshold) {
      _swipeDirection = SwipDirection.Left;
      _animateCard(Offset(-500, 0));
    } else {
      _animateCard(Offset.zero);
    }
  }

  bool _listEquals(List<AssetEntity> a, List<AssetEntity> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Future<void> _checkListCompleted() async {
    if (_localImages.isNotEmpty) {
      final completed =
          await MonthlyCompleteHelper.isListCompleted(_localImages);
      final listKey = widget.listKey ?? 'default';
      Future.microtask(() {
        ref.read(listCompletedProvider(listKey).notifier).state = completed;
      });
    }
  }

  void _onListPending() {
    final listKey = widget.listKey ?? 'default';
    Future.microtask(() {
      ref.read(listPendingProvider(listKey).notifier).state = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isIndexReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final listKey = widget.listKey ?? 'default';
    final images = ref.watch(swipeImagesProvider);
    final currentIndex = ref.watch(swipeIndexProvider(listKey));
    final isListCompleted = ref.watch(listCompletedProvider(listKey));
    final isPendingComplete = ref.watch(listPendingProvider(listKey));

    // Fotoğraf listesi güncellenirse local'i yenile
    if (!_listEquals(_localImages, images)) {
      _localImages = List<AssetEntity>.from(images);
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;

    if (currentIndex >= _localImages.length &&
        !isListCompleted &&
        !isPendingComplete) {
      // Liste bittiğinde pending olarak işaretle
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!ref.read(listPendingProvider(listKey))) {
          _onListPending();
          await MonthlyCompleteHelper.setListPending(_localImages);
        }
      });
    }
    if (currentIndex >= _localImages.length ||
        isListCompleted ||
        isPendingComplete) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Swipe', style: CustomTheme.textTheme(context).bodyLarge),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.05, vertical: height * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: height * 0.4,
                  width: width,
                  decoration: BoxDecoration(
                      color: CustomTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Lottie.asset('assets/icons/tik.json',
                          height: height * 0.33, width: width * 0.8),
                      Text(
                        'Swipe List Completed'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.01),
                if (!isListCompleted)
                  SwipeCompleteButton(
                    onPressed: () async {
                      await MonthlyCompleteHelper.clearPending(_localImages);
                      ref
                          .read(swipeIndexProvider(listKey).notifier)
                          .setIndex(0);
                      ref.read(listPendingProvider(listKey).notifier).state =
                          false;
                    },
                  ),
                Consumer(builder: (context, ref, _) {
                  final deleteCount =
                      ref.watch(deleteMapProvider)[listKey]?.length ?? 0;
                  return Container(
                    width: width * 0.999,
                    height: height * 0.06,
                    margin: EdgeInsets.symmetric(
                        horizontal: width * 0.001, vertical: height * 0.01),
                    child: ElevatedButton.icon(
                      onPressed: deleteCount == 0
                          ? null
                          : () async {
                              final deleteList = ref
                                      .read(deleteMapProvider)[listKey]
                                      ?.toList() ??
                                  [];
                              if (deleteList.isEmpty) return;
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeletePreviewPage(
                                    deleteList: deleteList,
                                    listKey: listKey,
                                  ),
                                ),
                              );
                            },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      label: Text(
                        '${'View to be Deleted'.tr()} ($deleteCount)',
                        style: CustomTheme.textTheme(context)
                            .bodySmall
                            ?.copyWith(color: Colors.red),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${currentIndex + 1} / ${_localImages.length}',
          style: CustomTheme.textTheme(context).bodyLarge,
        ),
      ),
      body: Center(
        child: SizedBox(
          width: size.width * 0.95,
          height: size.height * 0.8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Önceki kart yoksa boş
              if (currentIndex < _localImages.length)
                // Önceki kart (arka plan)
                Positioned.fill(
                  child: MediaPreview(
                    key: ValueKey(_localImages[
                            min(currentIndex + 1, _localImages.length - 1)]
                        .id),
                    media: currentIndex + 1 < _localImages.length
                        ? _localImages[currentIndex + 1]
                        : _localImages[currentIndex],
                    swipeLabel: null,
                    swipeLabelAlignment: null,
                  ),
                ),

              // Üstteki aktif kart
              if (currentIndex < _localImages.length)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final offset = _isDragging
                        ? _dragOffset
                        : (_animationController.isAnimating
                            ? _animation.value
                            : Offset.zero);
                    final angle = offset.dx / 500 * 0.2;
                    return Transform.translate(
                      offset: offset,
                      child: Transform.rotate(
                        angle: angle,
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: (details) =>
                              _onPanEnd(details, currentIndex),
                          child: MediaPreview(
                            key: ValueKey(_localImages[currentIndex].id),
                            media: _localImages[currentIndex],
                            swipeLabel: (_isDragging || _swipeDirection != null)
                                ? ((offset.dx > 50 ||
                                        _swipeDirection == SwipDirection.Right)
                                    ? 'Delete'
                                    : (offset.dx < -50 ||
                                            _swipeDirection ==
                                                SwipDirection.Left)
                                        ? 'Keep'
                                        : null)
                                : null,
                            swipeLabelAlignment: offset.dx > 0
                                ? Alignment.topLeft
                                : Alignment.topRight,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _localImages.isNotEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: height * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () =>
                          _onManualAction(SwipDirection.Left, currentIndex),
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.green,
                          padding:
                              EdgeInsets.symmetric(vertical: height * 0.005)),
                      child: Text('Keep',
                          style: CustomTheme.textTheme(context)
                              .bodyMedium
                              ?.copyWith(color: Colors.green)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () =>
                          _onManualAction(SwipDirection.Right, currentIndex),
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.red,
                          padding:
                              EdgeInsets.symmetric(vertical: height * 0.005)),
                      child: Text('Delete',
                          style: CustomTheme.textTheme(context)
                              .bodyMedium
                              ?.copyWith(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
