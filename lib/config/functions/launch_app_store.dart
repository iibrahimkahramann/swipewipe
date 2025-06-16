import 'package:url_launcher/url_launcher.dart';

Future<void> launchAppStore() async {
  final appStoreUrl =
      Uri.parse('https://apps.apple.com/app/6744528945?action=write-review');
  if (await canLaunchUrl(appStoreUrl)) {
    await launchUrl(appStoreUrl, mode: LaunchMode.externalApplication);
  } else {
    throw 'Uygulama sayfası açılamadı';
  }
}
