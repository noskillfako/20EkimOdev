/// Dosya: lib/features/search/presentation/search_providers.dart
/// Görev / İşlev: Arama ve filtreleme durumunu yöneten (VehicleFilterNotifier) ve
/// filtre kriterlerine göre filtrelenmiş araç listesini sağlayan Riverpod sağlayıcıları.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../vehicles/domain/vehicle.dart';
import '../../vehicles/presentation/vehicle_providers.dart';
import '../domain/vehicle_filter.dart';

/// Aktif araç filtresi durumunu yöneten Riverpod sağlayıcısı.
final vehicleFilterProvider = NotifierProvider<VehicleFilterNotifier, VehicleFilter>(() {
  return VehicleFilterNotifier();
});

/// Filtre durum değişikliklerini yöneten Notifier sınıfı.
class VehicleFilterNotifier extends Notifier<VehicleFilter> {
  /// Başlangıç durumunda boş ve varsayılan filtreyi üretir.
  @override
  VehicleFilter build() {
    return const VehicleFilter();
  }

  /// Filtre modelini doğrudan yeni bir filtre nesnesiyle günceller.
  void updateFilter(VehicleFilter newFilter) {
    state = newFilter;
  }

  /// Arama metnini günceller.
  void setQuery(String? query) {
    state = state.copyWith(query: query);
  }

  /// Sıralama ölçütünü günceller (ör. price_asc, newest, popularity).
  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  /// Arama metni ve sıralama hariç tüm ek filtreleri sıfırlar.
  void resetFilters() {
    state = VehicleFilter(query: state.query, sortBy: state.sortBy);
  }

  /// Tüm filtreleri, arama metnini ve sıralamayı tamamen sıfırlar.
  void clearAll() {
    state = const VehicleFilter();
  }
}

/// Tüm araç listesini güncel filtreye tabi tutarak filtrelenmiş araç listesini sunan sağlayıcı.
final filteredVehiclesProvider = Provider<List<Vehicle>>((ref) {
  final vehiclesAsync = ref.watch(vehiclesProvider);
  final filter = ref.watch(vehicleFilterProvider);

  return vehiclesAsync.maybeWhen(
    data: (vehicles) => filter.apply(vehicles),
    orElse: () => [],
  );
});
