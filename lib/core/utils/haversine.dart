/// Dosya: lib/core/utils/haversine.dart
/// Görev / İşlev: İki coğrafi koordinat (enlem ve boylam) arasındaki küresel kuş uçuşu
/// mesafeyi Haversine formülü ve trigonometrik hesaplamalarla kilometre (km) cinsinden hesaplar.
/// Araç arama ve filtreleme ekranında belirli yarıçap içindeki araçları bulmak için kullanılır.

import 'dart:math' as math;

// İki coğrafi koordinat (enlem ve boylam) arasındaki kuş uçuşu mesafeyi km cinsinden hesaplayan Haversine algoritması
class Haversine {
  // Sınıfın dışarıdan örneklenmesini engellemek için private yapıcı
  Haversine._();

  // Dünyanın ortalama yarıçapı (kilometre cinsinden)
  static const double earthRadiusKm = 6371.0;

  // İki koordinat noktası arasındaki mesafeyi (km) hesaplar
  static double calculateDistanceKm({
    required double lat1, // 1. Nokta Enlem (Örn: Kullanıcının konumu)
    required double lng1, // 1. Nokta Boylam
    required double lat2, // 2. Nokta Enlem (Örn: Aracın konumu)
    required double lng2, // 2. Nokta Boylam
  }) {
    // Enlem ve boylam farklarını radyan cinsine dönüştür
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);

    // Noktaların enlemlerini radyana dönüştür
    final rLat1 = _degreesToRadians(lat1);
    final rLat2 = _degreesToRadians(lat2);

    // Haversine formülü küresel trigonometri hesabı
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rLat1) * math.cos(rLat2) * math.sin(dLng / 2) * math.sin(dLng / 2);

    // Açısal mesafeyi (radyan) hesapla
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    // Yarıçapla çarparak kilometre cinsinden mesafeyi döndür
    return earthRadiusKm * c;
  }

  // Dereceyi radyana dönüştüren yardımcı fonksiyon
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
