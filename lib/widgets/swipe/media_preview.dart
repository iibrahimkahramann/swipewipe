import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/widgets/swipe/video_player_widget.dart';

class MediaPreview extends StatelessWidget {
  final AssetEntity media;

  const MediaPreview({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          return VideoPlayerWidget(
            videoFile: file,
            width: size.width,
            height: size.height * 0.99999,
          );
        } else {
          final bytes = snapshot.data as Uint8List;
          return _buildImageCard(context, bytes, size);
        }
      },
    );
  }

  Widget _buildImageCard(BuildContext context, Uint8List bytes, Size size) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.02, vertical: size.height * 0.01),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.memory(
            bytes,
            height: size.height * 0.7,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: size.height * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionButton(context, 'Sakla', Colors.green),
              _actionButton(context, 'Sil', Colors.red),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, Color color) {
    final size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Container(
      width: size.width * 0.35,
      height: size.height * 0.07,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
      ),
      child: Center(child: Text(label, style: textStyle)),
    );
  }
}
