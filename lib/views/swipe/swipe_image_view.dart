import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:swipewipe/widgets/swipe/dissimible_media_items.dart';
import 'package:swipewipe/providers/gallery/albums_media_provider.dart';
import 'package:swipewipe/providers/gallery/monthly_media_providers.dart';
import 'package:swipewipe/widgets/swipe/delete_alert_widget.dart';
import '../../components/organize/swipe_complete_button.dart';

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
  bool _listCompleted = false;
  bool _buttonPressed = false;
  bool _initialized = false;
  bool _showDeleteInfo = false;
  double _deletedKB = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _calculateFileSizes();
    await _checkListCompleted();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentImages = ref.read(swipeImagesProvider);
      if (currentImages.isEmpty && !_listCompleted) {
        ref.read(swipeImagesProvider.notifier).setImages(widget.mediaList);
        ref.read(swipeCurrentIndexProvider.notifier).state =
            widget.initialIndex;
        ref.read(swipePendingDeleteProvider.notifier).clear();
      }
    });
    setState(() {
      _initialized = true;
    });
  }

  Future<void> _calculateFileSizes() async {
    final sizes = <int>[];
    for (final asset in ref.read(swipeImagesProvider)) {
      final file = await asset.file;
      sizes.add(await file?.length() ?? 0);
    }
    _fileSizes = sizes;
    _loadingSizes = false;
  }

  Future<void> _checkListCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getListKey();
    _listCompleted = prefs.getBool(key) ?? false;
    _buttonPressed = !_listCompleted;
  }

  Future<void> _setListCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getListKey();
    await prefs.setBool(key, value);
    setState(() {
      _listCompleted = value;
      _buttonPressed = !value;
    });
  }

  String _getListKey() {
    if (widget.mediaList.isEmpty) return 'swipe_list_completed_empty';
    return 'swipe_list_completed_${widget.mediaList.first.id}_${widget.mediaList.last.id}';
  }

  Widget _buildCompletedView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.02,
            ),
            decoration: BoxDecoration(
              color: CustomTheme.secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Lottie.asset(
                  'assets/icons/tik.json',
                  width: width * 0.7,
                  height: height * 0.3,
                ),
                Text(
                  'Swipe List Completed'.tr(),
                  style: CustomTheme.textTheme(context).bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(height: width * 0.05),
          SwipeCompleteButton(
            onPressed: () async {
              await _setListCompleted(false);
              ref
                  .read(swipeImagesProvider.notifier)
                  .setImages(widget.mediaList);
              ref.read(swipeCurrentIndexProvider.notifier).state = 0;
              ref.read(swipePendingDeleteProvider.notifier).clear();
              setState(() {
                _buttonPressed = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllImagesProcessed(BuildContext context) {
    return Center(
      child: Text(
        "All images processed".tr(),
        style: CustomTheme.textTheme(context).bodyMedium,
      ),
    );
  }

  Widget _buildPageView(
      BuildContext context, List<AssetEntity> images, Size size) {
    return PageView.builder(
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
    );
  }

  Future<void> _handleBulkDelete(BuildContext context, Size size) async {
    final globalDeleteList = ref.read(globalDeleteProvider);
    if (globalDeleteList.isEmpty) return;
    int totalDeletedBytes = 0;
    try {
      for (final asset in globalDeleteList) {
        final file = await asset.file;
        totalDeletedBytes += await file?.length() ?? 0;
      }
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        debugPrint('Kullanıcı galeri silme izni vermedi');
        return;
      }
      final deleted = await PhotoManager.editor.deleteWithIds(
        globalDeleteList.map((e) => e.id).toList(),
      );
      if (deleted.isNotEmpty) {
        ref.read(globalDeleteProvider.notifier).clear();
        final _ = ref.refresh(albumListProvider);
        final __ = ref.refresh(monthlyMediaProvider);
        setState(() {
          _showDeleteInfo = true;
          _deletedKB = totalDeletedBytes / 1024;
        });
      } else {
        debugPrint('Silme işlemi başarısız veya kullanıcı izin vermedi.');
      }
    } catch (_) {
      debugPrint('Batch delete error occurred'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(swipeImagesProvider);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
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
                      onPressed: () => _handleBulkDelete(context, size),
                      tooltip: 'Bulk Delete (Trash)'.tr(),
                    ),
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
          body: !_initialized || _loadingSizes
              ? const Center(child: CircularProgressIndicator())
              : (_listCompleted && !_buttonPressed)
                  ? _buildCompletedView(context)
                  : (images.isEmpty)
                      ? (() {
                          if (!_listCompleted) {
                            _setListCompleted(true);
                          }
                          return _buildAllImagesProcessed(context);
                        })()
                      : _buildPageView(context, images, size),
        ),
        if (_showDeleteInfo)
          DeleteAlertWidget(
            deletedKB: _deletedKB,
            onClose: () {
              setState(() {
                _showDeleteInfo = false;
              });
            },
          ),
      ],
    );
  }
}
