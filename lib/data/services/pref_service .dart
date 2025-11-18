import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  PrefService._(); // private constructor
  static final PrefService instance = PrefService._();

  Future<void> enableUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("enableUpdate", true);
  }

  Future<void> disableUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("enableUpdate", false);
  }

  Future<bool> isUpdateCheckEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("enableUpdate") ?? false;
  }
}
