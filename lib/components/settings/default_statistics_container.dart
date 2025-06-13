import 'package:flutter/material.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

class DefaultStatistiscConainer extends StatelessWidget {
  const DefaultStatistiscConainer({
    super.key,
    required this.width,
    required this.height,
    required this.title,
  });

  final double width;
  final double height;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Text(
              title,
              style: CustomTheme.textTheme(context).bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
