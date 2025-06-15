import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        'Statistisc',
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
                title: 'Yükleniyor...',
              ),
              error: (e, _) => DefaultStatistiscConainer(
                width: width,
                height: height,
                title: 'Hata',
              ),
              data: (mediaList) => DefaultStatistiscConainer(
                width: width,
                height: height,
                title: '${mediaList.length} Fotoğraf',
              ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            DefaultStatistiscConainer(
              width: width,
              height: height,
              title: stats.isLoading
                  ? 'Yükleniyor...'
                  : '${stats.value?.savedCount ?? 0} Fotoğraf Saklandı',
            ),
            SizedBox(
              height: height * 0.01,
            ),
            DefaultStatistiscConainer(
              width: width,
              height: height,
              title: '${stats.value?.deletedCount ?? 0} Fotoğraf Silindi',
            ),
            SizedBox(
              height: height * 0.01,
            ),
            DefaultStatistiscConainer(
              width: width,
              height: height,
              title:
                  '${((stats.value?.deletedTotalBytes ?? 0) / 1024).toStringAsFixed(1)} KB Kaydedildi',
            ),
            SizedBox(
              height: height * 0.02,
            ),
            GestureDetector(
              onTap: () {
                context.go('/settings');
              },
              child: Container(
                height: height * 0.1,
                width: width,
                decoration: BoxDecoration(
                  color: CustomTheme.accentColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.elliptical(40, 40),
                    topRight: Radius.elliptical(40, 40),
                    bottomLeft: Radius.elliptical(30, 30),
                    bottomRight: Radius.elliptical(30, 30),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Geri Dön',
                    style: CustomTheme.textTheme(context).bodyMedium?.copyWith(
                          color: CustomTheme.backgroundColor,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
