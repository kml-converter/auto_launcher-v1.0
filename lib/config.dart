import 'package:shared_preferences/shared_preferences.dart';

class ConfigManager {
  // Carica le configurazioni salvate o restituisce i valori di fabbrica (fallback)
  static Future<Map<String, String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'logo': prefs.getString('car_logo') ??
          "Jeep RENEGADE", // Impostato di default sulla tua auto
      'mp3': prefs.getString('mp3_path') ??
          "Default/Music", // Evitiamo percorsi assoluti nativi bloccati
      'mp4': prefs.getString('mp4_path') ?? "Default/Movies",
    };
  }

  // Salva le nuove impostazioni inserite dall'utente
  static Future<void> save(String logo, String mp3, String mp4) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('car_logo', logo);
    await prefs.setString('mp3_path', mp3);
    await prefs.setString('mp4_path', mp4);
  }
}
