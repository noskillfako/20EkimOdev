import 'package:flutter/material.dart';
import '../../features/vehicles/domain/vehicle.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';
import 'rating_stars.dart';

// Araç listelerinde (Keşfet, Popüler, İlanlarım) kullanılan ana araç kartı bileşeni
class VehicleCard extends StatelessWidget {
  // Gösterilecek araç modeli
  final Vehicle vehicle;
  // Karta tıklandığında çalışacak callback (İlan detayına yönlendirir)
  final VoidCallback onTap;
  // Favoriye ekli olup olmadığını belirten durum
  final bool isFavorite;
  // Favori butonuna tıklandığında tetiklenecek fonksiyon
  final VoidCallback? onFavoriteToggle;
  // İsteğe bağlı benzersiz hero etiketi (IndexedStack çakışmalarını önlemek için)
  final String? heroTag;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    // Aktif tema verilerini alıyoruz
    final theme = Theme.of(context);

    // Araç görseli bileşeni (Hata durumunda yedek ikon gösterir)
    Widget imageWidget = Image.asset(
      vehicle.photos.isNotEmpty ? vehicle.photos.first : 'assets/mock/images/car_sedan_red.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.directions_car_rounded, size: 48),
        );
      },
    );

    // Eğer heroTag belirtilmişse akıcı geçiş animasyonu için Hero ile sarıyoruz
    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias, // Kenarları yuvarlatılmış köşelerden taşmasın
      child: InkWell(
        onTap: onTap, // Dokunma efekti (Ripple)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 16:9 formatında araç kapak fotoğrafı ve üzerindeki rozetler
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Araç fotoğrafı
                  imageWidget,

                  // Sol üst köşe: Konum / Şehir rozeti
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160), // Yarı saydam siyah arka plan
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            vehicle.city, // Şehir adı
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sağ üst köşe: Favorilere ekleme/çıkarma butonu
                  if (onFavoriteToggle != null)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Material(
                        color: Colors.black.withAlpha(160),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onFavoriteToggle, // Favori durumunu tersine çevirir
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFavorite ? AppColors.error : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Sol alt köşe: Durum rozeti (Araç aktif değilse veya kiradaysa uyarır)
                  if (!vehicle.isActive)
                    Positioned(
                      bottom: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: vehicle.isRented
                              ? AppColors.warning // Kirada uyarısı
                              : theme.colorScheme.onSurfaceVariant, // Duraklatıldı uyarısı
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          vehicle.isRented ? 'Şu Anda Kirada' : 'Yayında Değil',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Kartın alt kısmı: Araç bilgileri, puan ve fiyatlandırma
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Araç başlığı (Marka + Model) ve ortalama yıldız puanı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Dinamik yıldız bileşeni (ör. 4.8 ★ (24))
                      RatingStars(
                        rating: vehicle.ratingAvg,
                        count: vehicle.ratingCount,
                        starSize: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Araç özellikleri etiketleri (Yıl, KM, Yakıt, Vites)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildChip(theme, '${vehicle.modelYear}'), // Model yılı
                      _buildChip(theme, Formatters.formatKm(vehicle.km)), // Formatlı kilometre
                      _buildChip(theme, vehicle.fuelType.toUpperCase()), // Yakıt tipi (Benzin, Dizel vb.)
                      _buildChip(theme, vehicle.transmission.toUpperCase()), // Vites tipi (Otomatik / Manuel)
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.sm),

                  // Fiyat ve tamamlanan kiralama sayısı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Günlük kiralama fiyatı
                          Text(
                            Formatters.formatDailyPrice(vehicle.dailyPrice),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Depozito güvence bedeli
                          Text(
                            'Depozito: ${Formatters.formatCurrency(vehicle.deposit)}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      // Toplam başarılı kiralama geçmişi
                      Text(
                        '${vehicle.completedRentalCount} Kiralama',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Özellik etiketleri için yardımcı küçük rozet fonksiyonu
  Widget _buildChip(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
