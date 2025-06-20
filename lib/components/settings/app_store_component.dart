import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:swipewipe/config/functions/launch_app_store.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

class AppStoreComponent extends StatelessWidget {
  const AppStoreComponent({
    super.key,
    required this.width,
    required this.height,
    required this.urlPath,
    required this.imagePath,
    required this.title,
  });

  final double width;
  final double height;
  final String urlPath;
  final String imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchAppStore(urlPath);
      },
      child: Container(
        width: width,
        height: height * 0.065,
        decoration: BoxDecoration(
          color: CustomTheme.secondaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: width * 0.04),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: width * 0.09,
              ),
              SizedBox(
                width: width * 0.02,
              ),
              Text(
                title.tr(),
                style: CustomTheme.textTheme(context).bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
