import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:swipewipe/widgets/swipe/delete_alert_widget.dart';
import 'dart:typed_data';

class DeletePreviewPage extends ConsumerWidget {
  final List<AssetEntity> deleteList;
  final String listKey;

  const DeletePreviewPage(
      {super.key, required this.deleteList, required this.listKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final selected = ref.watch(selectedDeleteProvider(listKey));

    if (selected.isEmpty && deleteList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedDeleteProvider(listKey).notifier).state =
            deleteList.map((e) => e.id).toSet();
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Photos to be deleted'.tr(),
          style: CustomTheme.textTheme(context).bodySmall,
        ),
        actions: [
          IconButton(
            onPressed: selected.isEmpty
                ? null
                : () async {
                    final toDelete = deleteList
                        .where((e) => selected.contains(e.id))
                        .toList();
                    final toKeep = deleteList
                        .where((e) => !selected.contains(e.id))
                        .toList();
                    // Silinecek fotoğrafların toplam boyutunu hesapla
                    int totalBytes = 0;
                    final deletedBytesList = <int>[];
                    for (final asset in toDelete) {
                      final file = await asset.file;
                      if (file != null) {
                        totalBytes += await file.length();
                        deletedBytesList.add(await file.length());
                      }
                    }
                    // Silme işlemi
                    final deletedIds = await PhotoManager.editor
                        .deleteWithIds(toDelete.map((e) => e.id).toList());
                    final notifier = ref.read(deleteMapProvider.notifier);
                    for (final asset in toDelete) {
                      if (deletedIds.contains(asset.id)) {
                        notifier.remove(listKey, asset);
                      }
                    }
                    ref.read(selectedDeleteProvider(listKey).notifier).state =
                        toKeep.map((e) => e.id).toSet();
                    if (deletedIds.isNotEmpty) {
                      // İstatistik güncelle: silinen her fotoğraf için
                      final statsNotifier =
                          ref.read(userGalleryStatsProvider.notifier);
                      for (final bytes in deletedBytesList) {
                        await statsNotifier.addDeleted(bytes);
                      }
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => DeleteAlertWidget(
                          deletedKB: totalBytes / 1024,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      );
                    } else {
                      // Hiçbir fotoğrafı silme, tüm deleteList'i tekrar seçili yap
                      ref.read(selectedDeleteProvider(listKey).notifier).state =
                          deleteList.map((e) => e.id).toSet();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Bazı fotoğraflar silinemedi!')),
                      );
                    }
                  },
            icon: Image.asset(
              'assets/icons/delete.png',
              width: width * 0.07,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: height * 0.02,
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final currentDeleteList =
                ref.watch(deleteMapProvider)[listKey]?.toList() ?? [];
            final selected = ref.watch(selectedDeleteProvider(listKey));
            return GridView.builder(
              itemCount: currentDeleteList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                final asset = currentDeleteList[index];
                final isSelected = selected.contains(asset.id);
                return GestureDetector(
                  onTap: () {
                    final notifier =
                        ref.read(selectedDeleteProvider(listKey).notifier);
                    final current = Set<String>.from(notifier.state);
                    if (isSelected) {
                      current.remove(asset.id);
                    } else {
                      current.add(asset.id);
                    }
                    notifier.state = current;
                  },
                  child: FutureBuilder<Uint8List?>(
                    future: asset
                        .thumbnailDataWithSize(const ThumbnailSize(300, 300)),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: width * 0.02,
                              right: width * 0.02,
                              child: Icon(
                                CupertinoIcons.check_mark_circled_solid,
                                color: CupertinoColors.activeBlue,
                                size: width * 0.06,
                              ),
                            ),
                          if (!isSelected)
                            Positioned(
                              top: width * 0.02,
                              right: width * 0.02,
                              child: Icon(
                                CupertinoIcons.circle,
                                color: CupertinoColors.systemGrey,
                                size: width * 0.06,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
