import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

class OrganizeWeeklyComponent extends StatelessWidget {
  const OrganizeWeeklyComponent({
    super.key,
    required this.height,
    required this.width,
    required this.assets,
    required this.onTap,
  });

  final double height;
  final double width;
  final List<AssetEntity> assets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly',
            style: CustomTheme.textTheme(context).bodyMedium,
          ),
          SizedBox(
            height: height * 0.27,
            child: FutureBuilder<List<Uint8List?>>(
              future: Future.wait(assets.take(3).map((asset) =>
                  asset.thumbnailDataWithSize(const ThumbnailSize(400, 400)))),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final thumbnails = snapshot.data!;
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(thumbnails.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.01,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          thumbnails[index]!,
                          fit: BoxFit.cover,
                          width: width,
                          height: height,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
