import 'package:flutter/material.dart';

class OnboardingComponent extends StatelessWidget {
  const OnboardingComponent({
    super.key,
    required this.height,
    required this.width,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final double height;
  final double width;
  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: height * 0.05,
            bottom: height * 0.02,
          ),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.01),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Image.asset(imagePath, width: width * 0.9, height: height * 0.67),
      ],
    );
  }
}
