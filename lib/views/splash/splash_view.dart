import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    Future.delayed(
      const Duration(seconds: 2),
      () async {
        final prefs = await SharedPreferences.getInstance();
        final onboardingSeen = prefs.getBool('onboardingSeen') ?? false;
        if (onboardingSeen) {
          context.go('/onboarding');
        } else {
          context.go('/onboarding');
        }
      },
    );

    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/app_icon.png',
            width: width * 0.3,
          ),
          SizedBox(
            height: height * 0.01,
          ),
          Text(
            'Swipewipe',
            style: CustomTheme.textTheme(context).bodyLarge,
          )
        ],
      )),
    );
  }
}
