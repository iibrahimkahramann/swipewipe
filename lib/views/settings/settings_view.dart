import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swipewipe/components/settings/default_setting_container.dart';
import 'package:swipewipe/config/bar/appbar.dart';
import 'package:swipewipe/config/bar/navbar.dart';
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
            DefaultSettingContainer(
              width: width,
              height: height,
              imagePath: 'assets/icons/stats.png',
              text: 'Statistics',
              onTap: () => context.go('/statistics'),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            DefaultSettingContainer(
              width: width,
              height: height,
              imagePath: 'assets/icons/privacy.png',
              text: 'Privacy Policy',
              onTap: () {},
            ),
            SizedBox(
              height: height * 0.01,
            ),
            DefaultSettingContainer(
              width: width,
              height: height,
              imagePath: 'assets/icons/terms.png',
              text: 'Term Of Use',
              onTap: () {},
            ),
            SizedBox(
              height: height * 0.01,
            ),
            DefaultSettingContainer(
              width: width,
              height: height,
              imagePath: 'assets/icons/rate_us.png',
              text: 'Rate Us',
              onTap: () {},
            )
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentLocation: '/settings'),
    );
  }
}
