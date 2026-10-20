/// Dosya: lib/core/widgets/app_buttons.dart
/// Görev / İşlev: Uygulama genelinde kullanılan standart buton bileşenleridir.
/// Birincil aksiyon butonu (AppPrimaryButton), ikincil çerçeveli buton (AppSecondaryButton)
/// ve sade metin butonu (AppTextButton) için yüklenme göstergesi (loading) ve ikon desteği sağlar.

import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Birincil vurgulu işlem butonu (FilledButton tabanlı).
/// Form onaylama, kayıt olma, teklif verme gibi ana eylemlerde kullanılır.
class AppPrimaryButton extends StatelessWidget {
  final String text; // Buton üzerinde gösterilecek metin
  final VoidCallback? onPressed; // Tıklama aksiyonu (null ise buton devre dışı kalır)
  final bool isLoading; // True ise metin yerine dönen yükleme çarkı gösterilir
  final IconData? icon; // Metnin solunda yer alacak opsiyonel ikon
  final Color? backgroundColor; // İsteğe bağlı özel arka plan rengi
  final Color? foregroundColor; // İsteğe bağlı özel yazı/ikon rengi

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Buton arayüzünü çizen temel widget metodu.
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: (backgroundColor != null || foregroundColor != null)
          ? FilledButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
            )
          : null,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(text),
              ],
            ),
    );
  }
}

/// İkincil çerçeveli işlem butonu (OutlinedButton tabanlı).
/// Vazgeç, iptal et, filtreleri temizle gibi alternatif eylemlerde tercih edilir.
class AppSecondaryButton extends StatelessWidget {
  final String text; // Buton üzerinde gösterilecek metin
  final VoidCallback? onPressed; // Tıklama aksiyonu
  final bool isLoading; // True ise yüklenme çarkı gösterilir
  final IconData? icon; // Opsiyonel ikon

  const AppSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  /// İkincil buton arayüzünü çizen temel widget metodu.
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(text),
              ],
            ),
    );
  }
}

/// Çerçevesiz düz metin butonu (TextButton tabanlı).
/// Sayfa içi hızlı geçişler, 'Daha Fazla Gör', 'Giriş Yap' gibi sade tıklamalar için kullanılır.
class AppTextButton extends StatelessWidget {
  final String text; // Buton metni
  final VoidCallback? onPressed; // Tıklama fonksiyonu
  final IconData? icon; // Opsiyonel ikon
  final Color? color; // Özel metin rengi

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
  });

  /// Metin butonu arayüzünü çizen temel widget metodu.
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: color != null ? TextButton.styleFrom(foregroundColor: color) : null,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(text),
        ],
      ),
    );
  }
}
