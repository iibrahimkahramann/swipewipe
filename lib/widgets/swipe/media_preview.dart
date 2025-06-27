import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/widgets/swipe/video_player_widget.dart';
import 'package:video_player/video_player.dart'; // VideoPlayerController için

class MediaPreview extends StatefulWidget {
  final AssetEntity media;
  final String? swipeLabel;
  final Alignment? swipeLabelAlignment;
  final Uint8List? imageBytes; // Resimler için
  final VideoPlayerController? videoController; // Videolar için

  const MediaPreview({
    super.key,
    required this.media,
    this.swipeLabel,
    this.swipeLabelAlignment,
    this.imageBytes,
    this.videoController,
  });

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  @override
  void didUpdateWidget(covariant MediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Eğer yeni preload tamamlandıysa, widget güncellensin
    if (widget.media.id != oldWidget.media.id) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget content;
    bool needsRetry = false;
    if (widget.media.type == AssetType.video) {
      if (widget.videoController != null &&
          widget.videoController!.value.isInitialized) {
        content = VideoPlayerWidget(controller: widget.videoController!);
      } else {
        content = const Center(child: CircularProgressIndicator());
        needsRetry = true;
      }
    } else {
      if (widget.imageBytes != null) {
        content = Image.memory(
          widget.imageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        content = const Center(child: CircularProgressIndicator());
        needsRetry = true;
      }
    }

    // Retry mekanizması: preload tamamlanmadıysa kısa bir gecikmeyle tekrar build et
    if (needsRetry) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() {});
      });
    }

    // Overlay label if provided
    Widget overlayed = Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    if (widget.swipeLabel != null && widget.swipeLabelAlignment != null) {
      final isDelete = widget.swipeLabel == 'Delete';
      final borderColor = isDelete ? Colors.red : Colors.green;
      final textColor = borderColor;
      final labelText = isDelete ? 'Delete' : 'Keep';
      overlayed = Stack(
        children: [
          overlayed,
          Positioned(
            top: 12,
            left: widget.swipeLabelAlignment == Alignment.topLeft
                ? size.width * 0.04
                : null,
            right: widget.swipeLabelAlignment == Alignment.topRight
                ? size.width * 0.04
                : null,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02, vertical: size.width * 0.02),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border:
                    Border.all(color: borderColor, width: size.width * 0.012),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(labelText,
                    style: CustomTheme.textTheme(context)
                        .bodyLarge
                        ?.copyWith(color: textColor)),
              ),
            ),
          ),
        ],
      );
    }
    return overlayed;
  }
}
