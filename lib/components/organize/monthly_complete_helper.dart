import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';

class MonthlyCompleteHelper {
  static String getListKey(List<AssetEntity> assets) {
    if (assets.isEmpty) return 'swipe_list_completed_empty';
    final ids = assets.map((e) => e.id).join('_');
    return 'swipe_list_completed_$ids';
  }

  static String getPendingKey(List<AssetEntity> assets) {
    if (assets.isEmpty) return 'swipe_list_pending_empty';
    final ids = assets.map((e) => e.id).join('_');
    return 'swipe_list_pending_$ids';
  }

  static Future<bool> isListCompleted(List<AssetEntity> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final key = getListKey(assets);
    return prefs.getBool(key) ?? false;
  }

  static Future<void> completeList(List<AssetEntity> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final key = getListKey(assets);
    await prefs.setBool(key, true);
  }

  static Future<bool> isListPending(List<AssetEntity> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final key = getPendingKey(assets);
    return prefs.getBool(key) ?? false;
  }

  static Future<void> setListPending(List<AssetEntity> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final key = getPendingKey(assets);
    await prefs.setBool(key, true);
  }

  static Future<void> clearPending(List<AssetEntity> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final key = getPendingKey(assets);
    await prefs.remove(key);
  }
}
