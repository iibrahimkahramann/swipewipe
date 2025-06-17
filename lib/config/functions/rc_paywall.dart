import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

Future<void> homePaywall() async {}

class RevenueCatService {
  static Future<void> showPaywallIfNeeded() async {
    final paywallResult = await RevenueCatUI.presentPaywallIfNeeded("premium");
    print('Paywall result: $paywallResult');
  }
}
