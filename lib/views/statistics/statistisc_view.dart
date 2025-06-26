import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swipewipe/components/defaut_white_button.dart';
import 'package:swipewipe/components/settings/default_statistics_container.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:swipewipe/providers/gallery/gallery_permission_provider.dart';

class StatistiscView extends ConsumerStatefulWidget {
  const StatistiscView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatistiscViewState();
}

class _StatistiscViewState extends ConsumerState<StatistiscView> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final stats = ref.watch(userGalleryStatsProvider);
    final mediaAsync = ref.watch(mediaProvider);
    if (stats.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Statistisc'.tr(),
        style: CustomTheme.textTheme(context).bodyLarge,
      )),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: height * 0.02,
        ),
        child: Column(
          children: [
            Container(
              width: width,
              height: height * 0.38,
              decoration: BoxDecoration(
                color: CustomTheme.secondaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset('assets/images/statistics_image.png'),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            mediaAsync.when(
              loading: () => DefaultStatistiscConainer(
                width: width,
                height: height,
                title: tr('Loading'),
              ),
              error: (e, _) => DefaultStatistiscConainer(
                width: width,
                height: height,
                title: tr('Error'),
              ),
              data: (mediaList) {
                print('DEBUG: Total media: ${mediaList.length}');
                print('DEBUG: deletedCount: ${stats.value?.deletedCount}');
                print('DEBUG: savedCount: ${stats.value?.savedCount}');
                print(
                    'DEBUG: deletedTotalBytes: ${stats.value?.deletedTotalBytes}');
                return Column(
                  children: [
                    DefaultStatistiscConainer(
                      width: width,
                      height: height,
                      title: tr(
                        'Photo',
                        args: ['${mediaList.length}'],
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    DefaultStatistiscConainer(
                      width: width,
                      height: height,
                      title: tr(
                        'Photo Stored',
                        args: ['${stats.value?.savedCount ?? 0}'],
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    DefaultStatistiscConainer(
                      width: width,
                      height: height,
                      title: tr(
                        'Photo Deleted',
                        args: ['${stats.value?.deletedCount ?? 0}'],
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    DefaultStatistiscConainer(
                      width: width,
                      height: height,
                      title: tr('KB Deleted', args: [
                        ((stats.value?.deletedTotalBytes ?? 0) / 1024)
                            .toStringAsFixed(1)
                      ]),
                    ),
                  ],
                );
              },
            ),
            SizedBox(
              height: height * 0.02,
            ),
            DefaultWhiteButton(
              height: height,
              width: width,
              onTap: () {
                context.go("/settings");
              },
              title: 'Go Back'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
