import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';

class MonthlyCompleteHelper {
  static String getListKey(List<AssetEntity> assets) {
    if (assets.isEmpty) return 'swipe_list_completed_empty';
    return 'swipe_list_completed_${assets.first.id}_${assets.last.id}';
  }

  static Future<bool> isListCompleted(List<AssetEntity> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final key = getListKey(assets);
    return prefs.getBool(key) ?? false;
  }
}
