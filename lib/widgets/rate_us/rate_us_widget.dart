import 'package:flutter/material.dart';
import 'package:swipewipe/views/rate_us/rate_us_view.dart';

class RateUsDialogWithDelayedClose extends StatefulWidget {
  @override
  State<RateUsDialogWithDelayedClose> createState() =>
      RateUsDialogWithDelayedCloseState();
}

class RateUsDialogWithDelayedCloseState
    extends State<RateUsDialogWithDelayedClose> {
  bool _showClose = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showClose = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        SizedBox(
          width: height * 0.5,
          height: height * 0.5,
          child: RateUsView(),
        ),
        if (_showClose)
          Positioned(
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
      ],
    );
  }
}
