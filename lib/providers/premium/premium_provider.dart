import 'package:flutter_riverpod/flutter_riverpod.dart';

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier() : super(false) {
    _initializePremiumStatus();
  }

  Future<void> _initializePremiumStatus() async {
    // örnek: SharedPreferences ya da RevenueCat kontrolü vs.
    // final bool fromStorage = await loadPremiumStatus();
    // state = fromStorage;
  }

  Future<void> updatePremiumStatus(bool isPremium) async {
    state = isPremium;
  }
}

final isPremiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  return PremiumNotifier();
});
