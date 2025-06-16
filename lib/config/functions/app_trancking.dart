import 'package:app_tracking_transparency/app_tracking_transparency.dart';

Future<void> appTracking() async {
  print("ask att for ios");

  final TrackingStatus status =
      await AppTrackingTransparency.trackingAuthorizationStatus;

  while (status == TrackingStatus.notDetermined) {
    await Future.delayed(const Duration(seconds: 1));
    final TrackingStatus newStatus =
        await AppTrackingTransparency.requestTrackingAuthorization();
    if (newStatus != TrackingStatus.notDetermined) {
      break;
    }
  }
}

Future<void> nottrack() async {
  print("android version,skip att ask");
}
