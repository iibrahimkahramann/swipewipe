import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/swipe/swipe_background_witget.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'dart:math' as math;

class SwipeImagePage extends ConsumerStatefulWidget {
  final List<AssetEntity> mediaList;
  final int initialIndex;

  const SwipeImagePage({
    super.key,
    required this.mediaList,
    required this.initialIndex,
  });

  @override
  ConsumerState<SwipeImagePage> createState() => _SwipeImagePageState();
}

class _SwipeImagePageState extends ConsumerState<SwipeImagePage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(swipeImagesProvider.notifier).setImages(widget.mediaList);
      ref.read(swipeCurrentIndexProvider.notifier).state = widget.initialIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(swipeImagesProvider);
    ref.watch(swipeCurrentIndexProvider);

    if (images.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text(
          'Swipewipe',
          style: CustomTheme.textTheme(context).bodyLarge,
        )),
        body: Center(
            child: Text(
          "Tüm görseller işlendi",
          style: CustomTheme.textTheme(context)
              .bodyMedium
              ?.copyWith(color: Colors.white38),
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Swipewipe',
        style: CustomTheme.textTheme(context).bodyLarge,
      )),
      body: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        onPageChanged: (index) {
          ref.read(swipeCurrentIndexProvider.notifier).state = index;
        },
        itemBuilder: (context, index) {
          final img = images[index];

          return Dismissible(
            key: ValueKey(img.id),
            direction: DismissDirection.horizontal,
            background: swipeBackground(
              color: Colors.green.shade600,
              icon: Icons.archive_outlined,
              label: "Sakla",
              alignment: Alignment.centerLeft,
            ),
            secondaryBackground: swipeBackground(
              color: Colors.red.shade600,
              icon: Icons.delete_outline,
              label: "Sil",
              alignment: Alignment.centerRight,
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                ref.read(swipeImagesProvider.notifier).removeAt(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Saklandı",
                      style: CustomTheme.textTheme(context)
                          .bodyMedium
                          ?.copyWith(color: Colors.black),
                    ),
                  ),
                );
              } else {
                ref.read(swipeImagesProvider.notifier).removeAt(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Silindi",
                      style: CustomTheme.textTheme(context)
                          .bodyMedium
                          ?.copyWith(color: Colors.black),
                    ),
                  ),
                );
              }
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                // value: 0.0 → 1.0 arasında animasyon ilerlemesi
                return GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // sadece animasyon için dummy, kontrol Dismissible'da zaten
                  },
                  child: Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: (1 - value) * 0.05 * math.pi, // Hafif dönüş efekti
                      child: child,
                    ),
                  ),
                );
              },
              child: FutureBuilder(
                future:
                    img.thumbnailDataWithSize(const ThumbnailSize(800, 800)),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 600,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.memory(
                      snapshot.data!,
                      height: 600,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
