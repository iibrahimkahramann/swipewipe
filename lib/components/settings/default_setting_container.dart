import 'package:flutter/material.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';
import 'package:url_launcher/link.dart';

class DefaultSettingContainer extends StatelessWidget {
  const DefaultSettingContainer({
    super.key,
    required this.width,
    required this.height,
    required this.imagePath,
    required this.text,
    required this.urlPath,
  });

  final double width;
  final double height;
  final String imagePath;
  final String text;
  final String urlPath;

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: Uri.parse(urlPath),
      builder: (BuildContext context, Future<void> Function()? followLink) {
        return GestureDetector(
          onTap: followLink,
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
                    imagePath,
                    width: width * 0.06,
                  ),
                  SizedBox(
                    width: width * 0.03,
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
      },
    );
  }
}
