import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

class DeleteAlertWidget extends StatelessWidget {
  final double deletedKB;
  final VoidCallback onClose;
  const DeleteAlertWidget(
      {super.key, required this.deletedKB, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05, vertical: height * 0.05),
        child: Container(
          margin: EdgeInsets.only(top: height * 0.15),
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.08, vertical: height * 0.03),
          decoration: BoxDecoration(
            color: CustomTheme.secondaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/icons/tik.json',
                    width: width * 0.5,
                    height: height * 0.2,
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    'Successfully Deleted Selected Photos'.tr(),
                    style: CustomTheme.textTheme(context).bodyMedium?.copyWith(
                        color: Colors.white, decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    '${deletedKB.toStringAsFixed(1)} KB ${'Deleted'.tr()}',
                    style: CustomTheme.textTheme(context).bodySmall?.copyWith(
                        color: Colors.grey, decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
