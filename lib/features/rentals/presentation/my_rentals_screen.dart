import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/states.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/data/user_repository.dart';
import '../../reviews/data/review_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../domain/rental.dart';
import 'rental_providers.dart';

// Kiracının yaptığı kiralamaları (Aktif, Tamamlanan ve Onay Bekleyen) listeleyen ekran
class MyRentalsScreen extends ConsumerWidget {
  const MyRentalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Kiracının tüm kiralamalarını sağlayan Riverpod sağlayıcısı
    final rentalsAsync = ref.watch(renterRentalsProvider);

    return DefaultTabController(
      length: 3, // 3 sekme: Aktif, Tamamlanan, Bekleyen
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.navMyRentals, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          // Sekme Çubuğu (TabBar)
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Tamamlanan'),
              Tab(text: 'Bekleyen'),
            ],
          ),
        ),
        body: rentalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => AppErrorState(
            message: err.toString(),
            onRetry: () => ref.read(renterRentalsProvider.notifier).refresh(),
          ),
          data: (rentals) {
            // Durumlarına göre kiralamaları filtrele
            final activeRentals = rentals.where((r) => r.isActive).toList();
            final completedRentals = rentals.where((r) => r.isCompleted).toList();
            final pendingRentals = rentals.where((r) => r.isPending).toList();

            return TabBarView(
              children: [
                // 1. Sekme: Aktif Kiralamalar
                _buildRentalList(context, ref, activeRentals, 'Aktif kiralamanız bulunmamaktadır.'),
                // 2. Sekme: Tamamlanan Kiralamalar (Puanlama yapılabilir)
                _buildRentalList(context, ref, completedRentals, 'Geçmiş kiralama kaydınız bulunmamaktadır.', isCompletedTab: true),
                // 3. Sekme: Bekleyen Kiralamalar
                _buildRentalList(context, ref, pendingRentals, 'Bekleyen onayınız bulunmamaktadır.'),
              ],
            );
          },
        ),
      ),
    );
  }

  // Belirli bir kiralama listesini kaydırılabilir olarak çizen yardımcı metot
  Widget _buildRentalList(
    BuildContext context,
    WidgetRef ref,
    List<Rental> list,
    String emptyMessage, {
    bool isCompletedTab = false,
  }) {
    // Liste boşsa kullanıcıya boş durum ve keşfet butonu göster
    if (list.isEmpty) {
      return AppEmptyState(
        icon: Icons.car_rental_rounded,
        title: emptyMessage,
        actionText: 'Araçları Keşfet',
        onAction: () => context.go(AppRoutes.explore),
      );
    }

    // Çek-bırak ile yenileme (Pull to Refresh)
    return RefreshIndicator(
      onRefresh: () => ref.read(renterRentalsProvider.notifier).refresh(),
      child: ListView.separated(
        padding: AppSpacing.screenPadding,
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final rental = list[index];
          return _RentalCard(rental: rental, isCompletedTab: isCompletedTab);
        },
      ),
    );
  }
}

// Tek bir kiralama kaydını gösteren kart bileşeni
class _RentalCard extends ConsumerWidget {
  final Rental rental; // Kiralama nesnesi
  final bool isCompletedTab; // Tamamlanan sekmesinde mi gösteriliyor?

  const _RentalCard({required this.rental, this.isCompletedTab = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;
    final vehicleRepo = ref.watch(vehicleRepositoryProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    final reviewRepo = ref.watch(reviewRepositoryProvider);

    return FutureBuilder(
      // Araç bilgisi, araç sahibi ve daha önce puanlama yapılıp yapılmadığını paralel getir
      future: Future.wait([
        vehicleRepo.getVehicleById(rental.vehicleId),
        userRepo.getUserById(rental.ownerId),
        user != null ? reviewRepo.hasReviewedRental(rental.id, user.id) : Future.value(false),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const AppLoadingShimmer(height: 140, borderRadius: 16);
        }

        final vehicle = snapshot.data![0];
        final owner = snapshot.data![1];
        final hasReviewed = snapshot.data![2] as bool;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Araç Küçük Resmi
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: Image.asset(
                        vehicle.photos.isNotEmpty ? vehicle.photos.first : 'assets/mock/images/car_sedan_red.jpg',
                        width: 90,
                        height: 65,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Araç Başlığı
                          Text(
                            vehicle.title,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          // Araç Sahibi Adı
                          Text(
                            'Araç Sahibi: ${owner.name}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          // Durum Rozeti (Aktif, Tamamlandı, Onay Bekliyor vb.)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(rental.status).withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusText(rental.status),
                              style: TextStyle(
                                color: _getStatusColor(rental.status),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                // Tarih Aralığı ve Toplam Tutar Satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tarih Aralığı:', style: theme.textTheme.labelSmall),
                        Text(
                          '${Formatters.formatDateString(rental.startDate)} - ${Formatters.formatDateString(rental.endDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Toplam Tutar:', style: theme.textTheme.labelSmall),
                        Text(
                          Formatters.formatCurrency(rental.totalPrice),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Tamamlanan sekmesindeyse Karşılıklı Puanlama / Değerlendirme Bölümü
                if (isCompletedTab) ...[
                  const SizedBox(height: AppSpacing.md),
                  if (!hasReviewed)
                    // Henüz puanlanmadıysa Değerlendir Butonu
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.star,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () async {
                        final result = await AppDialogs.showRatingSheet(
                          context: context,
                          targetUserName: owner.name,
                          targetRoleText: 'Araç Sahibi',
                          includeVehicleRating: true, // Kiracı hem aracı hem araç sahibini puanlar
                        );

                        if (result != null && user != null) {
                          try {
                            await reviewRepo.addReview(
                              rentalId: rental.id,
                              vehicleId: rental.vehicleId,
                              reviewerId: user.id,
                              targetId: rental.ownerId,
                              targetRole: 'owner',
                              stars: result['userStars'] as int,
                              vehicleStars: result['vehicleStars'] as int?,
                              comment: result['comment'] as String,
                            );

                            if (context.mounted) {
                              AppDialogs.showSuccessSnackBar(context, 'Değerlendirmeniz kaydedildi! Teşekkür ederiz.');
                              ref.read(renterRentalsProvider.notifier).refresh();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppDialogs.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.star_rounded, size: 18),
                      label: const Text('Araç Sahibini ve Aracı Değerlendir'),
                    )
                  else
                    // Daha önce puanlandıysa Başarı Rozeti
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Bu kiralama başarıyla değerlendirildi',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Kiralama durumuna göre renk döndüren yardımcı fonksiyon
  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.primarySeed;
      case 'pending_confirmation':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  // Kiralama durumunun Türkçe açıklamasını döndüren yardımcı fonksiyon
  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Aktif Kiralama';
      case 'completed':
        return 'Tamamlandı';
      case 'pending_confirmation':
        return 'Onay Bekliyor';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return status;
    }
  }
}
