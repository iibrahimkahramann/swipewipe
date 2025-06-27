import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipewipe/components/settings/app_store_component.dart';
import 'package:swipewipe/components/settings/default_setting_container.dart';
import 'package:swipewipe/components/settings/statistics_card.dart';
import 'package:swipewipe/config/bar/appbar.dart';
import 'package:swipewipe/config/bar/navbar.dart';
import 'package:swipewipe/config/functions/rc_paywall.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:swipewipe/providers/premium/premium_provider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings'.tr(),
              style: CustomTheme.textTheme(context).bodyMedium,
            ),
            SizedBox(
              height: height * 0.01,
            ),
            StatisticsCard(),
            SizedBox(
              height: height * 0.01,
            ),
            if (!isPremium)
              GestureDetector(
                onTap: () async {
                  await RevenueCatService.showPaywallIfNeeded();
                },
                child: Container(
                  width: width,
                  height: height * 0.065,
                  decoration: BoxDecoration(
                    color: CustomTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: width * 0.05),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/pro.png',
                          width: width * 0.06,
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        Text(
                          'Get Premium'.tr(),
                          style: CustomTheme.textTheme(context).bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: height * 0.01,
            ),
            DefaultSettingContainer(
              width: width,
              height: height,
              imagePath: 'assets/icons/privacy.png',
              text: 'Privacy Policy'.tr(),
              urlPath:
                  'https://sites.google.com/view/swipecleanup-privacy-policy/ana-sayfa',
            ),
            SizedBox(
              height: height * 0.01,
            ),
            DefaultSettingContainer(
              width: width,
              height: height,
              imagePath: 'assets/icons/terms.png',
              text: 'Term of Use'.tr(),
              urlPath:
                  'https://sites.google.com/view/swipecleanup-term-of-use/ana-sayfa',
            ),
            SizedBox(
              height: height * 0.01,
            ),
            AppStoreComponent(
              width: width,
              height: height,
              urlPath:
                  'https://apps.apple.com/app/6747386188?action=write-review',
              imagePath: 'assets/icons/rate_us.png',
              title: 'Rate Us'.tr(),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            AppStoreComponent(
              width: width,
              height: height,
              urlPath: 'https://apps.apple.com/app/6744528945',
              imagePath: 'assets/images/cartoon.png',
              title: 'Cartoon AI - Action Figure',
            ),
            SizedBox(
              height: height * 0.01,
            ),
            AppStoreComponent(
              width: width,
              height: height,
              urlPath: 'https://apps.apple.com/app/6743310667',
              imagePath: 'assets/images/anti_theft.png',
              title: 'Don’t Touch My Phone AntiTheft',
            ),
            SizedBox(
              height: height * 0.01,
            ),
            AppStoreComponent(
              width: width,
              height: height,
              urlPath: 'https://apps.apple.com/app/6742395123',
              imagePath: 'assets/images/offplayer.png',
              title: 'OffPlayer - Music Play Offline'.tr(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentLocation: '/settings'),
    );
  }
}
