import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../vehicles/domain/vehicle.dart';
import '../../vehicles/presentation/vehicle_providers.dart';
import '../domain/vehicle_filter.dart';

final vehicleFilterProvider = NotifierProvider<VehicleFilterNotifier, VehicleFilter>(() {
  return VehicleFilterNotifier();
});

class VehicleFilterNotifier extends Notifier<VehicleFilter> {
  @override
  VehicleFilter build() {
    return const VehicleFilter();
  }

  void updateFilter(VehicleFilter newFilter) {
    state = newFilter;
  }

  void setQuery(String? query) {
    state = state.copyWith(query: query);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void resetFilters() {
    state = VehicleFilter(query: state.query, sortBy: state.sortBy);
  }

  void clearAll() {
    state = const VehicleFilter();
  }
}

final filteredVehiclesProvider = Provider<List<Vehicle>>((ref) {
  final vehiclesAsync = ref.watch(vehiclesProvider);
  final filter = ref.watch(vehicleFilterProvider);

  return vehiclesAsync.maybeWhen(
    data: (vehicles) => filter.apply(vehicles),
    orElse: () => [],
  );
});
