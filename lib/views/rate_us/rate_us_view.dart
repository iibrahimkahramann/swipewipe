import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:in_app_review/in_app_review.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

class RateUsView extends StatefulWidget {
  @override
  _RateUsViewState createState() => _RateUsViewState();
}

class _RateUsViewState extends State<RateUsView> {
  int _rating = 0;

  void _submitRating() async {
    if (_rating > 0) {
      // Kullanıcı puan verdiğinde bir daha gösterilmemesi için flag kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rate_us_shown', true);
      if (_rating >= 3) {
        final InAppReview inAppReview = InAppReview.instance;

        await inAppReview.openStoreListing(appStoreId: '6747386188');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanks for your feedback!'.tr(),
              style: CustomTheme.textTheme(context).bodyMedium,
            ),
          ),
        );
      }
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select star.'.tr(),
            style: CustomTheme.textTheme(context).bodyMedium,
          ),
        ),
      );
    }
  }

  Widget _buildStar(int index) {
    final height = MediaQuery.of(context).size.height;
    return IconButton(
      icon: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: height * 0.04,
      ),
      onPressed: () {
        setState(() {
          _rating = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/icons/rate_us.json', height: height * 0.2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.02),
              child: Center(
                child: Text(
                  'Your feedback is important to us!'.tr(),
                  style: CustomTheme.textTheme(context).bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildStar(index + 1)),
            ),
            SizedBox(height: height * 0.02),
            GestureDetector(
              onTap: _submitRating,
              child: Container(
                width: height * 0.25,
                height: height * 0.05,
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('Submit'.tr(),
                      style: CustomTheme.textTheme(context).bodySmall),
                ),
              ),
            ),

            // ElevatedButton(
            //   onPressed: _submitRating,
            //   child: Text('Gönder', style: TextStyle(fontSize: height * 0.025)),
            // ),
          ],
        ),
      ),
    );
  }
}
