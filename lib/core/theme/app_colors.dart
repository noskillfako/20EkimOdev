import 'package:flutter/material.dart';

// Uygulama genelinde kullanılan renk paleti ve tasarım belirteçleri (Color Tokens)
class AppColors {
  // Sınıfın dışarıdan örneklenmesini engellemek için private yapıcı metot
  AppColors._();

  // Ana marka ve vurgu tohum renkleri (M3 ColorScheme için temel)
  static const Color primarySeed = Color(0xFF0F52BA); // Safir Mavisi (Güven, kurumsal, dinamik)
  static const Color secondarySeed = Color(0xFF00A896); // Teal / Camgöbeği (Modern vurgu)

  // Durum ve anlam bildiren semantik renkler (Feedback Colors)
  static const Color success = Color(0xFF2E7D32); // Başarı, onay, aktif durum yeşili
  static const Color warning = Color(0xFFF57C00); // Uyarı, beklemede durum turuncusu
  static const Color error = Color(0xFFD32F2F); // Hata, iptal, kritik durum kırmızısı
  static const Color star = Color(0xFFFFB300); // Değerlendirme ve puan yıldızı sarısı

  // Açık Tema Yüzey ve Nötr Renkleri (Light Mode Neutrals)
  static const Color lightBg = Color(0xFFF8FAFC); // Açık tema arka plan rengi
  static const Color lightSurface = Color(0xFFFFFFFF); // Açık tema yüzey rengi
  static const Color lightCard = Color(0xFFFFFFFF); // Açık tema kart rengi
  static const Color lightBorder = Color(0xFFE2E8F0); // Açık tema kenarlık/çizgi rengi

  // Koyu Tema Yüzey ve Nötr Renkleri (Dark Mode Neutrals - Slate Tonları)
  static const Color darkBg = Color(0xFF0F172A); // Koyu tema arka plan rengi (Slate 900)
  static const Color darkSurface = Color(0xFF1E293B); // Koyu tema yüzey rengi (Slate 800)
  static const Color darkCard = Color(0xFF1E293B); // Koyu tema kart rengi
  static const Color darkBorder = Color(0xFF334155); // Koyu tema kenarlık/çizgi rengi (Slate 700)
}
