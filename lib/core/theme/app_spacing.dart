/// Dosya: lib/core/theme/app_spacing.dart
/// Görev / İşlev: Uygulamanın ızgara (grid) ve yerleşim sistemini belirleyen boşluk (spacing),
/// köşe yuvarlatma (border radius) ve ekran iç kenar boşlukları (padding) sabitlerini içerir.

import 'package:flutter/material.dart';

// Boşluk ve kenar yuvarlatma sabitleri sınıfı
class AppSpacing {
  // Sınıfın dışarıdan örneklenmesini engellemek için private constructor
  AppSpacing._();

  // Sabit Boşluk Değerleri (Spacing Scale)
  static const double xs = 4.0; // Ekstra küçük boşluk
  static const double sm = 8.0; // Küçük boşluk
  static const double md = 12.0; // Orta-küçük boşluk
  static const double lg = 16.0; // Standart boşluk (Temel ızgara birimi)
  static const double xl = 24.0; // Geniş boşluk
  static const double xxl = 32.0; // Ekstra geniş boşluk
  static const double xxxl = 48.0; // Çok geniş boşluk

  // Köşe Yuvarlatma Değerleri (Radius Scale)
  static const double radiusSm = 8.0; // Küçük köşe yuvarlatma (Rozetler, çipler)
  static const double radiusMd = 12.0; // Orta köşe yuvarlatma (Butonlar, metin kutuları)
  static const double radiusLg = 16.0; // Büyük köşe yuvarlatma (Kartlar)
  static const double radiusXl = 24.0; // Ekstra büyük köşe yuvarlatma (Diyaloglar, BottomSheet)

  // Ekran ve Bileşen Dolguları (Padding Presets)
  static const EdgeInsets screenPadding = EdgeInsets.all(lg); // Sayfa standart 4 yönden dolgusu
  static const EdgeInsets horizontalScreen = EdgeInsets.symmetric(horizontal: lg); // Sayfa yatay dolgusu
  static const EdgeInsets cardPadding = EdgeInsets.all(lg); // Kart iç dolgusu
}

