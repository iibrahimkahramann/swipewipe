import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipewipe/config/functions/firebase_analytics.dart';
import 'package:swipewipe/widgets/swipe/swipe_background_widget.dart';
import 'package:swipewipe/providers/swipe/swipe_provider.dart';
import 'package:swipewipe/widgets/swipe/media_preview.dart';
import 'package:swipewipe/providers/premium/premium_provider.dart';
import 'package:swipewipe/config/functions/rc_paywall.dart';

class DismissibleMediaItem extends ConsumerWidget {
  final AssetEntity media;
  final int index;
  final int fileSizeBytes;

  const DismissibleMediaItem({
    super.key,
    required this.media,
    required this.index,
    required this.fileSizeBytes,
  });

  static int _swipeCount = 0;
  static bool _limitReached = false;

  static Future<void> _loadLimitState() async {
    final prefs = await SharedPreferences.getInstance();
    _swipeCount = prefs.getInt('swipeCount') ?? 0;
    _limitReached = prefs.getBool('swipeLimitReached') ?? false;
  }

  static Future<void> _saveLimitState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('swipeCount', _swipeCount);
    await prefs.setBool('swipeLimitReached', _limitReached);
  }

  static Future<void> _resetLimitState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('swipeCount');
    await prefs.remove('swipeLimitReached');
    _swipeCount = 0;
    _limitReached = false;
  }

  Future<void> _onDismissed(
      BuildContext context, WidgetRef ref, DismissDirection direction) async {
    final isPremium = ref.read(isPremiumProvider);
    if (isPremium) {
      await _resetLimitState();
    } else {
      if (!_limitReached && _swipeCount == 0) {
        await _loadLimitState();
      }
      if (_limitReached) {
        print('Paywall açılıyor! (limit aşıldı)');
        await RevenueCatService.showPaywallIfNeeded();
        AnalyticsService.analytics.logEvent(
          name: 'swipe_limit_reached',
          parameters: {'swipeCount': _swipeCount},
        );
        return;
      }
      _swipeCount++;
      print('Swipe count: \\$_swipeCount');
      if (_swipeCount >= 15) {
        _limitReached = true;
        print('Paywall açılıyor! (15 swipe sonrası)');
        await _saveLimitState();
        await RevenueCatService.showPaywallIfNeeded();
        return;
      }
      await _saveLimitState();
    }
    ref.read(swipeImagesProvider.notifier).removeAt(index);
    if (direction == DismissDirection.endToStart) {
      ref.read(globalDeleteProvider.notifier).add(media);
      await ref
          .read(userGalleryStatsProvider.notifier)
          .addDeleted(fileSizeBytes);
    } else if (direction == DismissDirection.startToEnd) {
      await ref.read(userGalleryStatsProvider.notifier).addSaved();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(media.id),
      direction: DismissDirection.horizontal,
      background: swipeBackground(
        color: Colors.green.shade600,
        icon: Icons.archive_outlined,
        label: "Keep".tr(),
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: swipeBackground(
        color: Colors.red.shade600,
        icon: Icons.delete_outline,
        label: "Delete".tr(),
        alignment: Alignment.centerRight,
      ),
      onDismissed: (direction) async =>
          await _onDismissed(context, ref, direction),
      child: MediaPreview(media: media),
    );
  }
}
