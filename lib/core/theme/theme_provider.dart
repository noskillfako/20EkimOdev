/// Dosya: lib/core/theme/theme_provider.dart
/// Görev / İşlev: Uygulamanın aktif tema modunu (Sistem / Açık / Koyu) Riverpod ile yönetir,
/// kullanıcının tema tercihini SharedPreferences ile yerel cihaz hafızasında kalıcı olarak saklar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Aktif tema modu sağlayıcısı (UI'ın temayı dinlemesini sağlar)
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

// Tema modunu kontrol eden ve cihaz hafızasına kaydeden State Notifier sınıfı
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'app_theme_mode'; // SharedPreferences anahtarı

  /// Başlangıç durumunu belirler (Varsayılan: Sistem teması) ve kayıtlı tercihi yükler.
  @override
  ThemeMode build() {
    _loadFromPrefs();
    return ThemeMode.system;
  }

  /// Cihaz hafızasından (SharedPreferences) daha önce seçilmiş tema modunu asenkron olarak yükler.
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved == 'light') {
        state = ThemeMode.light;
      } else if (saved == 'dark') {
        state = ThemeMode.dark;
      } else if (saved == 'system') {
        state = ThemeMode.system;
      }
    } catch (_) {}
  }

  /// Kullanıcının yeni tema modu seçimini (light, dark, system) uygular ve cihaz hafızasına kaydeder.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {}
  }
}

