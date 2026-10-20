/// Dosya: lib/features/vehicles/presentation/popular_screen.dart
/// Görev / İşlev: Sistemdeki en popüler ve en çok tercih edilen kiralık araçları
/// öne çıkan afiş ve trend listesi halinde gösteren Popüler ekranı.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/vehicle_card.dart';
import 'vehicle_providers.dart';

/// Popüler ve trend araçların sergilendiği ekran widget'ı.
class PopularScreen extends ConsumerWidget {
  const PopularScreen({super.key});

  /// Popüler araçları asenkron sağlayıcıdan dinler ve arayüzü inşa eder.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final popularAsync = ref.watch(popularVehiclesProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, color: AppColors.warning),
            const SizedBox(width: AppSpacing.xs),
            Text(AppStrings.navPopular, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: popularAsync.when(
        loading: () => ListView.separated(
          padding: AppSpacing.screenPadding,
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) => const AppLoadingShimmer(height: 240, borderRadius: 16),
        ),
        error: (err, _) => AppErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(popularVehiclesProvider),
        ),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const AppEmptyState(
              icon: Icons.star_border_rounded,
              title: 'Henüz popüler ilan bulunmuyor',
            );
          }

          final featured = vehicles.first;
          final remaining = vehicles.skip(1).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(popularVehiclesProvider),
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                // Highlight Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer.withAlpha(120),
                        theme.colorScheme.secondaryContainer.withAlpha(80),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 28, color: AppColors.primarySeed),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Haftanın En Çok Tercih Edilenleri',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Tamamlanan kiralama sayısı ve kullanıcı puanlarına göre sıralanmıştır.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Featured Card
                Text('Günün Öne Çıkanı', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                VehicleCard(
                  vehicle: featured,
                  isFavorite: favorites.contains(featured.id),
                  onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggle(featured.id),
                  onTap: () => context.push(AppRoutes.vehicleDetailPath(featured.id)),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Remaining Popular Cars
                Text('Trend İlanlar', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                ...remaining.map((v) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: VehicleCard(
                        vehicle: v,
                        isFavorite: favorites.contains(v.id),
                        onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggle(v.id),
                        onTap: () => context.push(AppRoutes.vehicleDetailPath(v.id)),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
