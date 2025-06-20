import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

class SwipeCompleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SwipeCompleteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.79,
      height: height * 0.06,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomTheme.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text('Review Again'.tr(),
            style: CustomTheme.textTheme(context).bodySmall),
      ),
    );
  }
}
