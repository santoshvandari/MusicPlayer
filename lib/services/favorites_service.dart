import 'package:hive/hive.dart';

class FavoritesService {
  static Future<void> addFavorite(String songPath) async {
    final box = await Hive.openBox('favorites');
    box.add(songPath);
  }

  static Future<List<String>> getFavorites() async {
    final box = await Hive.openBox('favorites');
    return box.values.cast<String>().toList();
  }

  static Future<void> removeFavorite(String songPath) async {
    final box = await Hive.openBox('favorites');
    final key = box.keys.firstWhere((k) => box.get(k) == songPath);
    box.delete(key);
  }
}
