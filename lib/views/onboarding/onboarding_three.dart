import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipewipe/components/defaut_white_button.dart';
import 'package:swipewipe/components/onboarding/onboarding_component.dart';

class OnboardingThree extends StatelessWidget {
  const OnboardingThree({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.02,
          vertical: height * 0.02,
        ),
        child: Column(
          children: [
            Expanded(
              child: OnboardingComponent(
                height: height,
                width: width,
                title: 'Reclaim the Landfill!'.tr(),
                subtitle:
                    'You can delete unnecessary photos and track them in the statistics.'
                        .tr(),
                imagePath: 'assets/images/onboarding_stats.png',
              ),
            ),
            DefaultWhiteButton(
              height: height,
              width: width * 0.99,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboardingSeen', true);
                context.go('/organize');
              },
              title: 'Get Started'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
