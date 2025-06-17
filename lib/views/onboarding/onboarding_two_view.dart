import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swipewipe/components/defaut_white_button.dart';
import 'package:swipewipe/components/onboarding/onboarding_component.dart';

class OnboardingTwoView extends StatelessWidget {
  const OnboardingTwoView({super.key});

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
                title: 'Monthly Organization.'.tr(),
                subtitle:
                    'Go through your photos in date-based groups. Clean up more regularly.'
                        .tr(),
                imagePath: 'assets/images/onboarding_home.png',
              ),
            ),
            DefaultWhiteButton(
              height: height,
              width: width * 0.99,
              onTap: () {
                context.go('/onboarding-three');
              },
              title: 'Continue'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
