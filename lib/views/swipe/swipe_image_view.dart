import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/swipe/swipe_background_witget.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:swipewipe/providers/swipe/video_player_witget.dart';
import 'package:flutter/services.dart'; // hata kontrolü için

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

  Future<void> _deleteSelectedAssets() async {
    final assets = ref.read(swipePendingDeleteProvider);
    if (assets.isEmpty) return;

    try {
      await PhotoManager.editor.deleteWithIds(assets.map((e) => e.id).toList());
      ref.read(swipePendingDeleteProvider.notifier).clear();
    } catch (e) {
      print('hata');
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(swipeImagesProvider);
    ref.watch(swipeCurrentIndexProvider);
    final toBeDeleted = ref.watch(swipePendingDeleteProvider);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (images.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Swipewipe',
            style: CustomTheme.textTheme(context).bodyLarge,
          ),
        ),
        body: Center(
          child: Text(
            "Tüm görseller işlendi",
            style: CustomTheme.textTheme(context)
                .bodyMedium
                ?.copyWith(color: Colors.white38),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Swipewipe',
          style: CustomTheme.textTheme(context).bodyLarge,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed:
                    toBeDeleted.isNotEmpty ? _deleteSelectedAssets : null,
                tooltip: 'Seçilenleri Sil',
              ),
              if (toBeDeleted.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${toBeDeleted.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
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
              if (direction == DismissDirection.endToStart) {
                ref.read(swipePendingDeleteProvider.notifier).add(img);
              }

              ref.read(swipeImagesProvider.notifier).removeAt(index);
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return GestureDetector(
                  child: Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: (1 - value) * 0.05 * math.pi,
                      child: child,
                    ),
                  ),
                );
              },
              child: FutureBuilder(
                future: img.type == AssetType.video
                    ? img.file
                    : img.thumbnailDataWithSize(const ThumbnailSize(600, 600)),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 600,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (img.type == AssetType.video) {
                    final file = snapshot.data as File;
                    return VideoPlayerWidget(
                      videoFile: file,
                      width: width,
                      height: height * 0.7, // Önemli! Görselle eşleştirildi
                    );
                  } else {
                    final bytes = snapshot.data as Uint8List;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Image.memory(
                            bytes,
                            height: height * 0.7,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: height * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: width * 0.35,
                                height: height * 0.07,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.green,
                                ),
                                child: Center(
                                    child: Text(
                                  'Sakla',
                                  style:
                                      CustomTheme.textTheme(context).bodyMedium,
                                )),
                              ),
                              Container(
                                width: width * 0.35,
                                height: height * 0.07,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.red,
                                ),
                                child: Center(child: Text('Sil')),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
