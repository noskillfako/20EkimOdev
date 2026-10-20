import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class OwnerRentalsScreen extends ConsumerWidget {
  const OwnerRentalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ownerRentalsAsync = ref.watch(ownerRentalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.navRentalHistory, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: ownerRentalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorState(message: err.toString()),
        data: (rentals) {
          if (rentals.isEmpty) {
            return const AppEmptyState(
              icon: Icons.history_rounded,
              title: 'Henüz kiralama işlemi bulunmuyor',
              subtitle: 'Araçlarınız kiralandığında işlem adımları burada görünecektir.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(ownerRentalsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: rentals.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final rental = rentals[index];
                return _OwnerRentalCard(rental: rental);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OwnerRentalCard extends ConsumerWidget {
  final Rental rental;

  const _OwnerRentalCard({required this.rental});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;
    final vehicleRepo = ref.watch(vehicleRepositoryProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    final reviewRepo = ref.watch(reviewRepositoryProvider);

    return FutureBuilder(
      future: Future.wait([
        vehicleRepo.getVehicleById(rental.vehicleId),
        userRepo.getUserById(rental.renterId),
        user != null ? reviewRepo.hasReviewedRental(rental.id, user.id) : Future.value(false),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const AppLoadingShimmer(height: 150, borderRadius: 16);
        }

        final vehicle = snapshot.data![0];
        final renter = snapshot.data![1];
        final hasReviewed = snapshot.data![2] as bool;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Image.asset(
                        vehicle.photos.isNotEmpty ? vehicle.photos.first : 'assets/mock/images/car_sedan_red.jpg',
                        width: 70,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vehicle.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Kiracı: ${renter.name} (${renter.phone})', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Text(
                            rental.status == 'completed'
                                ? 'Tamamlandı'
                                : (rental.status == 'active' ? 'Aktif Kirada' : 'Onay Bekliyor'),
                            style: TextStyle(
                              color: rental.status == 'completed'
                                  ? AppColors.primarySeed
                                  : (rental.status == 'active' ? AppColors.success : AppColors.warning),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${Formatters.formatDateString(rental.startDate)} - ${Formatters.formatDateString(rental.endDate)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      Formatters.formatCurrency(rental.totalPrice),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Actions
                if (rental.isActive) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primarySeed),
                    icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
                    label: const Text('Aracı İade Al ve Kiralamayı Tamamla'),
                    onPressed: () async {
                      final confirm = await AppDialogs.showConfirmDialog(
                        context: context,
                        title: 'İade Onayı',
                        message: 'Aracı eksiksiz teslim aldığınızı onaylıyor musunuz? Depozito çözülecektir.',
                        confirmText: 'İadeyi Onayla',
                      );
                      if (confirm) {
                        await ref.read(ownerRentalsProvider.notifier).confirmReturn(rental.id);
                        if (context.mounted) {
                          AppDialogs.showSuccessSnackBar(context, 'Kiralama başarıyla tamamlandı!');
                        }
                      }
                    },
                  ),
                ] else if (rental.isCompleted) ...[
                  if (!hasReviewed)
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.star_rounded, size: 18, color: AppColors.star),
                      label: const Text('Kiracıyı Puanla ve Yorum Yap'),
                      onPressed: () async {
                        final result = await AppDialogs.showRatingSheet(
                          context: context,
                          targetUserName: renter.name,
                          targetRoleText: 'Kiracı',
                          includeVehicleRating: false,
                        );

                        if (result != null && user != null) {
                          try {
                            await reviewRepo.addReview(
                              rentalId: rental.id,
                              vehicleId: null,
                              reviewerId: user.id,
                              targetId: rental.renterId,
                              targetRole: 'renter',
                              stars: result['userStars'] as int,
                              comment: result['comment'] as String,
                            );

                            if (context.mounted) {
                              AppDialogs.showSuccessSnackBar(context, 'Kiracı değerlendirmeniz kaydedildi!');
                              ref.read(ownerRentalsProvider.notifier).refresh();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppDialogs.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
                            }
                          }
                        }
                      },
                    )
                  else
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Kiracı değerlendirildi',
                          style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
