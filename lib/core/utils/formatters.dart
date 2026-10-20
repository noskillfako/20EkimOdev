/// Dosya: lib/core/utils/formatters.dart
/// Görev / İşlev: Uygulama genelindeki sayısal ve zamansal verilerin kullanıcı dostu
/// Türkçe formatta sunulmasını sağlar (TL para birimi simgesi, günlük fiyat, binlik basamaklı km,
/// Türkçe ay isimli tarih, araç yaşı ve doğum tarihinden kullanıcı yaşı hesabı).

import 'package:intl/intl.dart';

// Para birimi, tarih, kilometre, yaş ve puan formatlamaları için yardımcı sınıf
class Formatters {
  // Sınıfın dışarıdan örneklenmesini engellemek için private yapıcı
  Formatters._();

  // Türkçe sayı formatlayıcı (Örn: 1.250)
  static final _numberFormat = NumberFormat('#,###', 'tr_TR');

  // Para tutarını TL simgesiyle formatlar (Örn: "1.500 ₺")
  static String formatCurrency(num amount) {
    return '${_numberFormat.format(amount)} ₺';
  }

  // Günlük kiralama ücretini formatlar (Örn: "1.250 ₺/gün")
  static String formatDailyPrice(num amount) {
    return '${_numberFormat.format(amount)} ₺/gün';
  }

  // Kilometre değerini formatlar (Örn: "45.000 km")
  static String formatKm(num km) {
    return '${_numberFormat.format(km)} km';
  }

  // Puan ve yorum sayısını formatlar (Örn: "4.8 (24)")
  static String formatRating(double rating, [int? count]) {
    final r = rating.toStringAsFixed(1);
    if (count != null) {
      return '$r ($count)';
    }
    return r;
  }

  // DateTime nesnesini Türkçe ay adıyla formatlar (Örn: "15 Ekim 2026")
  static String formatDate(DateTime date) {
    final months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  // ISO 8601 string tarihini Türkçe formata dönüştürür (Hata durumunda orijinali döndürür)
  static String formatDateString(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return formatDate(dt);
    } catch (_) {
      return isoDate;
    }
  }

  // Araç model yılından aracın yaşını hesaplar
  static int calculateAge(int modelYear) {
    final currentYear = DateTime.now().year;
    return currentYear - modelYear;
  }

  // Doğum tarihinden kullanıcının yaşını tam olarak hesaplar
  static int calculateUserAge(String birthDateIso) {
    try {
      final dt = DateTime.parse(birthDateIso);
      final now = DateTime.now();
      int age = now.year - dt.year;
      // Doğum günü henüz bu yıl gelmediyse yaşı bir azalt
      if (now.month < dt.month || (now.month == dt.month && now.day < dt.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }
}
