import 'package:flutter/material.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

class DefaultSettingContainer extends StatelessWidget {
  const DefaultSettingContainer({
    super.key,
    required this.width,
    required this.height,
    required this.imagePath,
    required this.text,
    required this.onTap,
  });

  final double width;
  final double height;
  final String imagePath;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height * 0.07,
        decoration: BoxDecoration(
          color: CustomTheme.secondaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
          ),
          child: Row(
            children: [
              Image.asset(
                imagePath,
              ),
              SizedBox(
                width: width * 0.02,
              ),
              Text(
                text,
                style: CustomTheme.textTheme(context).bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
