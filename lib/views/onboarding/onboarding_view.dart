import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swipewipe/components/defaut_white_button.dart';
import 'package:swipewipe/components/onboarding/onboarding_component.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

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
                title: 'Just Swipe!'.tr(),
                subtitle:
                    'Easily clean up your photo gallery. Swipe right, keep. Swipe left, delete.'
                        .tr(),
                imagePath: 'assets/images/onboarding_swipe.png',
              ),
            ),
            DefaultWhiteButton(
              height: height,
              width: width * 0.99,
              onTap: () async {
                context.go('/onboarding-two');
              },
              title: 'Continue'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
