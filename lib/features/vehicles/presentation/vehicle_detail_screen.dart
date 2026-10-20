import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/domain/chat.dart';
import '../../profile/data/user_repository.dart';
import '../../reviews/data/review_repository.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';
import 'vehicle_providers.dart';

// Araç Detay Ekranı (Foto Galeri, Teknik Bilgiler, Araç Sahibi Profili, Yorumlar ve Teklif Verme)
class VehicleDetailScreen extends ConsumerStatefulWidget {
  final String vehicleId; // Detayı gösterilecek aracın benzersiz kimliği

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  // Fotoğraf galerisinde aktif olarak görüntülenen fotoğrafın indeksi
  int _activePhotoIndex = 0;

  // Tarih seçimi yaparak kiralama teklifi oluşturma ve sohbet odasına yönlendirme metodu
  Future<void> _handleMakeOffer(Vehicle vehicle) async {
    // 1. Giriş kontrolü
    final user = ref.read(authControllerProvider).value;
    if (user == null) {
      context.push(AppRoutes.login);
      return;
    }

    // 2. Kendi aracına teklif vermeyi engelle
    if (vehicle.ownerId == user.id) {
      AppDialogs.showInfoDialog(
        context: context,
        title: 'Uyarı',
        message: AppStrings.cannotRentOwnVehicle,
      );
      return;
    }

    // 3. Varsayılan kiralama tarih aralığı (2 gün sonrası ile 5 gün sonrası arası)
    final initialRange = DateTimeRange(
      start: DateTime.now().add(const Duration(days: 2)),
      end: DateTime.now().add(const Duration(days: 5)),
    );

    // 4. Tarih Aralığı Seçim Takvimi (DateRangePicker)
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: initialRange,
      helpText: 'Kiralama Tarihlerini Seçiniz',
    );

    if (pickedRange == null || !mounted) return;

    // 5. Gün sayısı ve toplam fiyat hesaplama
    final days = pickedRange.duration.inDays > 0 ? pickedRange.duration.inDays : 1;
    final totalPrice = days * vehicle.dailyPrice;

    // 6. Onay iletişim kutusu göster
    final confirm = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Teklif Gönderilsin mi?',
      message:
          '$days gün için toplam ${Formatters.formatCurrency(totalPrice)} tutarındaki teklif araç sahibine iletilecektir.',
      confirmText: 'Teklif Gönder',
    );

    // 7. Onaylandıysa sohbet odası oluşturup teklif mesajını gönder
    if (confirm && mounted) {
      final chatRepo = ref.read(chatRepositoryProvider);
      final chat = await chatRepo.getOrCreateChat(
        vehicleId: vehicle.id,
        ownerId: vehicle.ownerId,
        renterId: user.id,
      );

      final offer = Offer(
        startDate: pickedRange.start.toIso8601String().split('T').first,
        endDate: pickedRange.end.toIso8601String().split('T').first,
        dailyPrice: vehicle.dailyPrice,
        totalPrice: totalPrice,
        status: 'pending', // Beklemede durumunda teklif
      );

      await chatRepo.sendMessage(
        chatId: chat.id,
        senderId: user.id,
        text: '${Formatters.formatCurrency(totalPrice)} kiralama teklifi gönderildi.',
        offer: offer,
      );

      if (mounted) {
        AppDialogs.showSuccessSnackBar(context, 'Teklifiniz iletildi!');
        context.push(AppRoutes.chatRoomPath(chat.id)); // Sohbet ekranına geç
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicleRepo = ref.watch(vehicleRepositoryProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    final reviewRepo = ref.watch(reviewRepositoryProvider);
    final favorites = ref.watch(favoritesProvider);
    final currentUser = ref.watch(authControllerProvider).value;

    return FutureBuilder(
      future: vehicleRepo.getVehicleById(widget.vehicleId), // Araç verisini asenkron getir
      builder: (context, AsyncSnapshot<Vehicle> snapshot) {
        // Yükleniyor durumu
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final vehicle = snapshot.data!;
        // Kullanıcı bu aracın sahibi mi kontrolü
        final isOwner = currentUser?.id == vehicle.ownerId;
        // Araç favorilerde mi kontrolü
        final isFav = favorites.contains(vehicle.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 1. Üst Kaydırılabilir Fotoğraf Galerisi (SliverAppBar)
              SliverAppBar(
                expandedHeight: 280, // Galeri yüksekliği
                pinned: true, // Üstte sabit kalma özelliği
                actions: [
                  // Favori Butonu (Kalp İkonu)
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? AppColors.error : null,
                    ),
                    onPressed: () => ref.read(favoritesProvider.notifier).toggle(vehicle.id),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Sayfalanabilir yatay resim kaydırıcı
                      PageView.builder(
                        itemCount: vehicle.photos.length,
                        onPageChanged: (idx) => setState(() => _activePhotoIndex = idx),
                        itemBuilder: (context, index) {
                          return Image.asset(
                            vehicle.photos[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      // Galeri sayfa gösterge noktaları (Dots Indicator)
                      if (vehicle.photos.length > 1)
                        Positioned(
                          bottom: AppSpacing.md,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(vehicle.photos.length, (idx) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _activePhotoIndex == idx ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _activePhotoIndex == idx ? Colors.white : Colors.white.withAlpha(120),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 2. Araç Detay İçeriği
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık, Şehir ve Puan Başlığı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primarySeed),
                                    const SizedBox(width: 4),
                                    Text(
                                      vehicle.city,
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Puan Yıldızları ve Sayısı
                          RatingStars(
                            rating: vehicle.ratingAvg,
                            count: vehicle.ratingCount,
                            starSize: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Hızlı Özellik Rozetleri (Model Yılı, KM, Yakıt, Vites)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickSpec(theme, Icons.calendar_today_rounded, '${vehicle.modelYear}', 'Model'),
                          _buildQuickSpec(theme, Icons.speed_rounded, Formatters.formatKm(vehicle.km), 'Kilometre'),
                          _buildQuickSpec(theme, Icons.local_gas_station_rounded, vehicle.fuelType.toUpperCase(), 'Yakıt'),
                          _buildQuickSpec(theme, Icons.settings_rounded, vehicle.transmission.toUpperCase(), 'Vites'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Araç Açıklaması
                      Text('Araç Açıklaması', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(vehicle.description, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: AppSpacing.xl),

                      // Teknik Özellikler Tablosu
                      Text(AppStrings.technicalSpecs, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.sm),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              _buildSpecRow('Kasa Tipi', vehicle.bodyType.toUpperCase()),
                              const Divider(height: 16),
                              _buildSpecRow('Renk', vehicle.color),
                              const Divider(height: 16),
                              if (vehicle.engineCc != null) ...[
                                _buildSpecRow('Motor Hacmi', '${vehicle.engineCc} cc'),
                                const Divider(height: 16),
                              ],
                              _buildSpecRow('Koltuk Sayısı', '${vehicle.seats} Kişilik'),
                              const Divider(height: 16),
                              if (vehicle.fuelConsumption != null) ...[
                                _buildSpecRow('Ortalama Tüketim', '${vehicle.fuelConsumption} L/100km'),
                                const Divider(height: 16),
                              ],
                              _buildSpecRow('Günlük KM Limiti', '${vehicle.dailyKmLimit} km'),
                              const Divider(height: 16),
                              _buildSpecRow('Depozito', Formatters.formatCurrency(vehicle.deposit)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Araç Sahibi Bilgi Kartı
                      Text(AppStrings.ownerInfo, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.sm),
                      FutureBuilder(
                        future: userRepo.getUserById(vehicle.ownerId),
                        builder: (context, AsyncSnapshot<dynamic> ownerSnapshot) {
                          if (!ownerSnapshot.hasData) {
                            return const AppLoadingShimmer(height: 80, borderRadius: 16);
                          }
                          final owner = ownerSnapshot.data!;

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  // Sahip Profil Fotoğrafı ve Doğrulama Rozeti
                                  UserAvatar(
                                    name: owner.name,
                                    radius: 26,
                                    isVerified: owner.isCriminalRecordVerified,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              owner.name,
                                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            if (owner.isCriminalRecordVerified) ...[
                                              const SizedBox(width: 4),
                                              const Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
                                            ],
                                          ],
                                        ),
                                        Text(
                                          '${owner.profession} • ${owner.ownerProfile?.ratingAvg ?? 5.0} ★ (${owner.ownerProfile?.ratingCount ?? 0} değerlendirme)',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        Text(
                                          '${owner.ownerProfile?.rentedOutCount ?? 0} Araç Kiralattı',
                                          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.primarySeed),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Sahiple Sohbet Başlat Butonu
                                  if (!isOwner)
                                    IconButton.filledTonal(
                                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                                      tooltip: 'Sohbet Başlat',
                                      onPressed: () async {
                                        if (currentUser == null) {
                                          context.push(AppRoutes.login);
                                          return;
                                        }
                                        final chatRepo = ref.read(chatRepositoryProvider);
                                        final chat = await chatRepo.getOrCreateChat(
                                          vehicleId: vehicle.id,
                                          ownerId: vehicle.ownerId,
                                          renterId: currentUser.id,
                                        );
                                        if (context.mounted) {
                                          context.push(AppRoutes.chatRoomPath(chat.id));
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Araç Değerlendirmeleri ve Kullanıcı Yorumları
                      Text('Kullanıcı Yorumları', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.sm),
                      FutureBuilder(
                        future: reviewRepo.getReviewsForVehicle(vehicle.id),
                        builder: (context, AsyncSnapshot<List<dynamic>> revSnapshot) {
                          if (!revSnapshot.hasData) {
                            return const AppLoadingShimmer(height: 100, borderRadius: 16);
                          }
                          final revs = revSnapshot.data!;
                          if (revs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('Bu araç için henüz yorum bulunmuyor.'),
                            );
                          }

                          return Column(
                            children: revs.take(5).map((r) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          RatingStars(rating: (r.vehicleStars ?? 5).toDouble(), starSize: 14),
                                          Text(
                                            Formatters.formatDateString(r.createdAt),
                                            style: theme.textTheme.labelSmall,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(r.comment, style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 100), // Sabit alt bar için boşluk
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. Sabit Alt Aksiyon Çubuğu (Günlük Fiyat ve Teklif Ver Butonu)
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80))),
              ),
              child: Row(
                children: [
                  // Fiyat Bilgisi
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.dailyPrice, style: theme.textTheme.labelSmall),
                      Text(
                        Formatters.formatDailyPrice(vehicle.dailyPrice),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  // Teklif Ver Butonu
                  Expanded(
                    child: FilledButton(
                      style: isOwner
                          ? FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              foregroundColor: theme.colorScheme.onSurfaceVariant,
                            )
                          : null,
                      onPressed: isOwner ? null : () => _handleMakeOffer(vehicle),
                      child: Text(isOwner ? 'Kendi İlanınız' : AppStrings.makeOffer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Hızlı teknik özellik kutucuğu oluşturan yardımcı widget
  Widget _buildQuickSpec(ThemeData theme, IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }

  // Teknik özellik satırı oluşturan yardımcı widget
  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
