import 'package:shared_preferences/shared_preferences.dart';

class ConditionVolService {
  static const _key = 'condition_vol_level';

  Future<int?> loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key);
  }

  Future<void> saveLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, level);
  }
}
