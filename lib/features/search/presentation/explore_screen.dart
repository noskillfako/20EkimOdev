import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/vehicle_card.dart';
import '../../vehicles/presentation/vehicle_providers.dart';
import 'filter_sheet.dart';
import 'search_providers.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(vehicleFilterProvider).query ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortSheet(BuildContext context) {
    final currentSort = ref.read(vehicleFilterProvider).sortBy;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final options = [
          ('recommended', AppStrings.sortRecommended, Icons.auto_awesome_rounded),
          ('price_asc', AppStrings.sortPriceAsc, Icons.arrow_upward_rounded),
          ('price_desc', AppStrings.sortPriceDesc, Icons.arrow_downward_rounded),
          ('newest', AppStrings.sortNewest, Icons.calendar_today_rounded),
          ('rating', AppStrings.sortRating, Icons.star_rounded),
          ('popularity', AppStrings.sortPopularity, Icons.trending_up_rounded),
        ];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  AppStrings.sortBy,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ...options.map((opt) {
                final isSelected = currentSort == opt.$1;
                return ListTile(
                  leading: Icon(opt.$3, color: isSelected ? Theme.of(ctx).colorScheme.primary : null),
                  title: Text(
                    opt.$2,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(ctx).colorScheme.primary : null,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check_rounded) : null,
                  onTap: () {
                    ref.read(vehicleFilterProvider.notifier).setSortBy(opt.$1);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(vehicleFilterProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final filteredVehicles = ref.watch(filteredVehiclesProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.navExplore, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filtrele',
            onPressed: () => FilterSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sırala',
            onPressed: () => _showSortSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    controller: _searchController,
                    hintText: AppStrings.searchVehicles,
                    leading: const Icon(Icons.search_rounded, size: 20),
                    trailing: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(vehicleFilterProvider.notifier).setQuery(null);
                          },
                        ),
                    ],
                    onChanged: (val) {
                      ref.read(vehicleFilterProvider.notifier).setQuery(val.trim());
                    },
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                      theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Filter badge button
                Badge(
                  isLabelVisible: filter.activeFilterCount > 0,
                  label: Text('${filter.activeFilterCount}'),
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () => FilterSheet.show(context),
                    child: const Icon(Icons.filter_list_rounded),
                  ),
                ),
              ],
            ),
          ),

          // Active filter chips row
          if (filter.hasActiveFilters)
            Container(
              height: 38,
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.close_rounded, size: 14),
                    label: const Text('Filtreleri Temizle'),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(vehicleFilterProvider.notifier).resetFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  if (filter.centerCity != null)
                    Chip(
                      label: Text('${filter.centerCity} (${filter.radiusKm?.toInt() ?? 50}km)'),
                    ),
                  if (filter.brands != null && filter.brands!.isNotEmpty)
                    Chip(label: Text('Marka: ${filter.brands!.join(", ")}')),
                  if (filter.fuelTypes != null && filter.fuelTypes!.isNotEmpty)
                    Chip(label: Text('Yakıt: ${filter.fuelTypes!.join(", ")}')),
                  if (filter.bodyTypes != null && filter.bodyTypes!.isNotEmpty)
                    Chip(label: Text('Kasa: ${filter.bodyTypes!.join(", ")}')),
                ],
              ),
            ),

          // Vehicles list
          Expanded(
            child: vehiclesAsync.when(
              loading: () => ListView.separated(
                padding: AppSpacing.screenPadding,
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                itemBuilder: (context, index) => const AppLoadingShimmer(height: 240, borderRadius: 16),
              ),
              error: (err, _) => AppErrorState(
                message: err.toString(),
                onRetry: () => ref.read(vehiclesProvider.notifier).refresh(),
              ),
              data: (_) {
                if (filteredVehicles.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.directions_car_filled_outlined,
                    title: AppStrings.noResults,
                    subtitle: AppStrings.tryBroadeningFilters,
                    actionText: AppStrings.clearFilters,
                    onAction: () {
                      _searchController.clear();
                      ref.read(vehicleFilterProvider.notifier).resetFilters();
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(vehiclesProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: AppSpacing.screenPadding,
                    itemCount: filteredVehicles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, index) {
                      final vehicle = filteredVehicles[index];
                      final isFav = favorites.contains(vehicle.id);

                      return VehicleCard(
                        vehicle: vehicle,
                        isFavorite: isFav,
                        onFavoriteToggle: () {
                          ref.read(favoritesProvider.notifier).toggle(vehicle.id);
                        },
                        onTap: () {
                          context.push(AppRoutes.vehicleDetailPath(vehicle.id));
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
