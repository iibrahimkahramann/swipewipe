import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeleteAlertWidget extends StatelessWidget {
  final double deletedKB;
  const DeleteAlertWidget({super.key, required this.deletedKB});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Deleted'.tr()),
      content: Column(
        children: [
          const SizedBox(height: 8),
          Text('Successfully Deleted Selected Photos'.tr()),
          const SizedBox(height: 8),
          Text('${deletedKB.toStringAsFixed(1)} KB ${'Deleted'.tr()}'),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: Text('OK'.tr()),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
