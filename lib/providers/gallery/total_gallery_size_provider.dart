import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipewipe/providers/gallery/gallery_permission_provider.dart';

final totalGallerySizeProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  const String _cacheKey = 'cached_total_gallery_size';
  const String _timestampKey = 'cached_total_gallery_size_timestamp';
  const Duration _cacheDuration =
      Duration(hours: 24); // Önbellek geçerlilik süresi

  final cachedSize = prefs.getInt(_cacheKey);
  final cachedTimestamp = prefs.getInt(_timestampKey);

  if (cachedSize != null && cachedTimestamp != null) {
    final lastUpdated = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
    if (DateTime.now().difference(lastUpdated) < _cacheDuration) {
      // Eğer önbellek geçerliyse, doğrudan önbelleğe alınmış değeri döndür
      return cachedSize;
    }
  }

  // Önbellek yoksa veya süresi dolmuşsa yeniden hesapla
  // mediaProvider'ı burada ref.read ile okuyarak,
  // totalGallerySizeProvider'ın sadece mediaProvider tamamlandığında tetiklenmesini sağlıyoruz.
  // Ancak mediaProvider'ın kendisi her zaman yeniden çalışabilir.
  final mediaList = await ref.read(mediaProvider.future); // Burayı değiştirdim

  int totalSize = 0;
  for (final asset in mediaList) {
    final file = await asset.file;
    if (file != null) {
      totalSize += await file.length();
    }
  }

  // Yeni değeri önbelleğe al
  await prefs.setInt(_cacheKey, totalSize);
  await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);

  return totalSize;
});