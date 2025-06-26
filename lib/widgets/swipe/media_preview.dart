import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/widgets/swipe/video_player_widget.dart';

class MediaPreview extends StatelessWidget {
  final AssetEntity media;
  final String? swipeLabel;
  final Alignment? swipeLabelAlignment;

  const MediaPreview({
    super.key,
    required this.media,
    this.swipeLabel,
    this.swipeLabelAlignment,
  });

  static final Map<String, Uint8List> _thumbnailCache = {};
  static final Map<String, File> _videoFileCache = {};

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget content;
    if (media.type == AssetType.video &&
        _videoFileCache.containsKey(media.id)) {
      final file = _videoFileCache[media.id]!;
      content = VideoPlayerWidget(
        videoFile: file,
        width: size.width,
        height: size.height * 0.99999,
      );
    } else if (media.type != AssetType.video &&
        _thumbnailCache.containsKey(media.id)) {
      final bytes = _thumbnailCache[media.id]!;
      content = _buildImageCard(context, bytes, size);
    } else {
      return FutureBuilder(
        future: media.type == AssetType.video
            ? media.file
            : media.thumbnailDataWithSize(const ThumbnailSize(600, 600)),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: size.height * 0.02,
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (media.type == AssetType.video) {
            final file = snapshot.data as File;
            _videoFileCache[media.id] = file;
            return VideoPlayerWidget(
              videoFile: file,
              width: size.width,
              height: size.height * 0.99999,
            );
          } else {
            final bytes = snapshot.data as Uint8List;
            _thumbnailCache[media.id] = bytes;
            return _buildImageCard(context, bytes, size);
          }
        },
      );
    }

    // Overlay label if provided
    Widget overlayed = content;
    if (swipeLabel != null && swipeLabelAlignment != null) {
      final isDelete = swipeLabel == 'Delete';
      final borderColor = isDelete ? Colors.red : Colors.green;
      final textColor = borderColor;
      final labelText = isDelete ? 'Delete' : 'Keep';
      overlayed = Stack(
        children: [
          content,
          Positioned(
            top: 12,
            left: swipeLabelAlignment == Alignment.topLeft ? 24 : null,
            right: swipeLabelAlignment == Alignment.topRight ? 24 : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: borderColor, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  labelText,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return overlayed;
  }

  Widget _buildImageCard(BuildContext context, Uint8List bytes, Size size) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Image.memory(
              bytes,
              height: size.height * 0.999,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
