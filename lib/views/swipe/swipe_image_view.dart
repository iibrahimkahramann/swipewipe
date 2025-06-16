import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:swipewipe/widgets/swipe/dissimible_media_items.dart';
import 'package:swipewipe/providers/gallery/albums_media_provider.dart';
import 'package:swipewipe/providers/gallery/monthly_media_providers.dart';

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
  late final PageController _pageController;
  List<int> _fileSizes = [];
  bool _loadingSizes = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _calculateFileSizes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentImages = ref.read(swipeImagesProvider);
      if (currentImages.isEmpty) {
        ref.read(swipeImagesProvider.notifier).setImages(widget.mediaList);
        ref.read(swipeCurrentIndexProvider.notifier).state =
            widget.initialIndex;
        ref.read(swipePendingDeleteProvider.notifier).clear();
      }
    });
  }

  Future<void> _calculateFileSizes() async {
    final sizes = <int>[];
    for (final asset in ref.read(swipeImagesProvider)) {
      final file = await asset.file;
      sizes.add(await file?.length() ?? 0);
    }
    setState(() {
      _fileSizes = sizes;
      _loadingSizes = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(swipeImagesProvider);
    final size = MediaQuery.of(context).size;

    if (_loadingSizes) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (images.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text(
          'Swipewipe',
          style: CustomTheme.textTheme(context).bodyLarge,
        )),
        body: Center(child: Text("Tüm görseller işlendi")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Swipewipe',
          style: CustomTheme.textTheme(context).bodyLarge,
        ),
        actions: [
          SizedBox(
            width: size.width * 0.13,
            height: size.width * 0.13,
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.delete, size: size.width * 0.07),
                  onPressed: () async {
                    final globalDeleteList = ref.read(globalDeleteProvider);
                    if (globalDeleteList.isEmpty) return;
                    try {
                      await PhotoManager.editor.deleteWithIds(
                          globalDeleteList.map((e) => e.id).toList());
                      ref.read(globalDeleteProvider.notifier).clear();
                      final _ = ref.refresh(albumListProvider);
                      // ignore: non_constant_identifier_names
                      final __ = ref.refresh(monthlyMediaProvider);
                    } catch (_) {
                      debugPrint('Toplu silme hatası oluştu');
                    }
                  },
                  tooltip: 'Toplu Sil (Çöp Kutusu)',
                ),
                // Badge tasarımı
                Positioned(
                  right: size.width * 0.02,
                  top: size.height * 0.002,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final count = ref.watch(globalDeleteProvider).length;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: EdgeInsets.all(size.width * 0.012),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        onPageChanged: (index) =>
            ref.read(swipeCurrentIndexProvider.notifier).state = index,
        itemBuilder: (context, index) {
          return DismissibleMediaItem(
            media: images[index],
            index: index,
            fileSizeBytes: _fileSizes.length > index ? _fileSizes[index] : 0,
          );
        },
      ),
    );
  }
}
