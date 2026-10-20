/// Dosya: lib/core/dialogs/app_dialogs.dart
/// Görev / İşlev: Uygulama genelinde standart modal iletişim pencerelerini (AlertDialog),
/// onay diyaloglarını, başarı/hata bildirim çubuklarını (SnackBar) ve kiralama sonrası
/// puanlama ve değerlendirme alt sayfasını (ModalBottomSheet) yöneten yardımcı sınıftır.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

// İletişim kutuları, onay diyalogları, bildirim çubukları (SnackBar) ve değerlendirme alt sayfası yöneticisi
class AppDialogs {
  // Sınıfın dışarıdan örneklenmesini engellemek için private yapıcı
  AppDialogs._();

  // Onay ve iptal seçenekleri sunan AlertDialog (Örn: Çıkış yap, İlan sil, Teklifi reddet)
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title, // İletişim kutusu başlığı
    required String message, // Açıklama metni
    String confirmText = 'Onayla', // Onay buton metni
    String cancelText = 'Vazgeç', // İptal buton metni
    bool isDestructive = false, // Kritik/silme işlemi mi (Kırmızı buton rengi için)
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Arka plana tıklayarak kapanmayı engelle
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text(title, style: theme.textTheme.titleLarge),
          content: Text(message, style: theme.textTheme.bodyMedium),
          actions: [
            // Vazgeç butonu
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelText),
            ),
            // Onayla butonu (Kritik işlemse hata/kırmızı rengi alır)
            FilledButton(
              style: isDestructive
                  ? FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    )
                  : null,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return result ?? false; // Sonuç null ise false dön
  }

  // Kullanıcıya bilgi veren tek butonlu AlertDialog
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Tamam',
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text(title, style: theme.textTheme.titleLarge),
          content: Text(message, style: theme.textTheme.bodyMedium),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  // Başarılı işlem bildirimi (Yeşil zemin ve onay ikonuyla yüzen SnackBar)
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Önceki bildirimi gizle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20), // Başarı ikonu
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success, // Semantik yeşil arka plan
      ),
    );
  }

  // Hata bildirimi (Kırmızı zemin ve uyarı ikonuyla yüzen SnackBar)
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20), // Hata ikonu
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error, // Semantik kırmızı arka plan
      ),
    );
  }

  // Tamamlanan kiralama için karşılıklı puanlama ve değerlendirme ModalBottomSheet penceresi
  static Future<Map<String, dynamic>?> showRatingSheet({
    required BuildContext context,
    required String targetUserName, // Puanlanan kişinin adı
    required String targetRoleText, // Puanlanan rol ('Kiracı' veya 'Araç Sahibi')
    bool includeVehicleRating = false, // Araç puanlaması da dahil edilsin mi? (Kiracı aracı puanlarken true)
  }) async {
    int userStars = 5; // Varsayılan kullanıcı puanı
    int vehicleStars = 5; // Varsayılan araç puanı
    final commentController = TextEditingController(); // Yorum metin kutusu denetleyicisi

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true, // Klavyenin alt sayfayı yukarı itmesi için true
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final bottomInset = MediaQuery.of(context).viewInsets.bottom; // Açık klavye yüksekliği

            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.sm,
                bottom: bottomInset + AppSpacing.xl, // Klavyenin üstünde kalacak şekilde alt boşluk
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Değerlendirme Başlığı
                    Text(
                      'Kiralama Değerlendirmesi',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Açıklama
                    Text(
                      '$targetUserName ($targetRoleText) ile kiralama deneyiminizi puanlayın',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // 1. Kullanıcı Puanı Yıldız Seçimi
                    Text(
                      '$targetRoleText Puanı:',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNum = index + 1;
                        return IconButton(
                          onPressed: () => setState(() => userStars = starNum),
                          icon: Icon(
                            starNum <= userStars ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: AppColors.star,
                            size: 36,
                          ),
                        );
                      }),
                    ),

                    // 2. Eğer kiracı değerlendirme yapıyorsa Araç Puanlamasını da göster
                    if (includeVehicleRating) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Araç Kondisyonu ve Temizliği:',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starNum = index + 1;
                          return IconButton(
                            onPressed: () => setState(() => vehicleStars = starNum),
                            icon: Icon(
                              starNum <= vehicleStars ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: AppColors.star,
                              size: 36,
                            ),
                          );
                        }),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),

                    // 3. Yorum Metin Kutusu
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Yorumunuz',
                        hintText: 'Deneyiminizi paylaşın (isteğe bağlı)...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 4. Gönder Butonu
                    FilledButton(
                      onPressed: () {
                        // Seçilen yıldızları ve yorumu içeren haritayı döndür
                        Navigator.of(ctx).pop({
                          'userStars': userStars,
                          'vehicleStars': includeVehicleRating ? vehicleStars : null,
                          'comment': commentController.text.trim(),
                        });
                      },
                      child: const Text('Değerlendirmeyi Gönder'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
