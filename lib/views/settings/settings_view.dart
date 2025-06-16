import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swipewipe/components/settings/default_setting_container.dart';
import 'package:swipewipe/config/bar/appbar.dart';
import 'package:swipewipe/config/bar/navbar.dart';
import 'package:swipewipe/config/functions/launch_app_store.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: CustomTheme.textTheme(context).bodyMedium,
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Container(
              width: width,
              height: height * 0.155,
              decoration: BoxDecoration(
                color: CustomTheme.secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            GestureDetector(
              onTap: () {
                context.go('/statistics');
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
                        'assets/icons/stats.png',
                        width: width * 0.06,
                      ),
                      SizedBox(
                        width: width * 0.03,
                      ),
                      Text(
                        'Statistics',
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
              text: 'Privacy Policy',
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
              text: 'Term Of Use',
              urlPath:
                  'https://sites.google.com/view/swipecleanup-term-of-use/ana-sayfa',
            ),
            SizedBox(
              height: height * 0.01,
            ),
            GestureDetector(
              onTap: () {
                launchAppStore();
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
                        'assets/icons/rate_us.png',
                        width: width * 0.06,
                      ),
                      SizedBox(
                        width: width * 0.03,
                      ),
                      Text(
                        'Rate Us',
                        style: CustomTheme.textTheme(context).bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentLocation: '/settings'),
    );
  }
}
