import 'package:url_launcher/url_launcher.dart';

Future<void> launchAppStore(String url) async {
  final appStoreUrl = Uri.parse(url);
  if (await canLaunchUrl(appStoreUrl)) {
    await launchUrl(appStoreUrl, mode: LaunchMode.externalApplication);
  } else {
    throw 'Uygulama sayfası açılamadı';
  }
}
