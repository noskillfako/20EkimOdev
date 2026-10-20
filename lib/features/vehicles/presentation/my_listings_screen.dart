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
import 'vehicle_providers.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ownerVehiclesAsync = ref.watch(ownerVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.navMyListings, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addVehicle),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.addNewListing),
      ),
      body: ownerVehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(ownerVehiclesProvider),
        ),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return AppEmptyState(
              icon: Icons.directions_car_filled_outlined,
              title: 'Henüz ilanınız bulunmuyor',
              subtitle: 'Aracınızı kiraya vererek ek gelir elde etmeye hemen başlayın.',
              actionText: AppStrings.addNewListing,
              onAction: () => context.push(AppRoutes.addVehicle),
            );
          }

          final activeCount = vehicles.where((v) => v.isActive).length;
          final pausedCount = vehicles.where((v) => v.isPaused).length;

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(ownerVehiclesProvider),
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                // Summary Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(80),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(theme, 'Toplam İlan', '${vehicles.length}'),
                      _buildStat(theme, 'Yayında', '$activeCount', color: AppColors.success),
                      _buildStat(theme, 'Duraklatılan', '$pausedCount', color: AppColors.warning),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Vehicle list
                ...vehicles.map((v) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            child: Image.asset(
                              v.photos.isNotEmpty ? v.photos.first : 'assets/mock/images/car_sedan_red.jpg',
                              width: 60,
                              height: 45,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(v.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${Formatters.formatDailyPrice(v.dailyPrice)} • ${v.city}'),
                          trailing: Switch(
                            value: v.isActive,
                            onChanged: (val) async {
                              final confirm = await AppDialogs.showConfirmDialog(
                                context: context,
                                title: val ? 'İlanı Yayına Al' : 'İlanı Duraklat',
                                message: val
                                    ? 'Bu ilan aramalarda yeniden görünür hale gelecektir.'
                                    : 'Bu ilan aramalarda gizlenecektir.',
                                confirmText: val ? 'Yayına Al' : 'Duraklat',
                              );
                              if (confirm) {
                                await ref.read(vehiclesProvider.notifier).toggleStatus(v.id, val);
                                ref.invalidate(ownerVehiclesProvider);
                              }
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${v.completedRentalCount} Kiralama • ${v.ratingAvg} ★ (${v.ratingCount})',
                                style: theme.textTheme.labelMedium,
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.visibility_outlined, size: 16),
                                label: const Text('İlanı İncele'),
                                onPressed: () => context.push(AppRoutes.vehicleDetailPath(v.id)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 80), // Fab spacing
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(ThemeData theme, String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
