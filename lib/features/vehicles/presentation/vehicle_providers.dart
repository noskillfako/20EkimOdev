/// Dosya: lib/features/vehicles/presentation/vehicle_providers.dart
/// Görev / İşlev: Araç listesi durumunu (VehiclesNotifier), popüler araçları, araç sahibinin
/// araçlarını ve favori araç ID'lerini yöneten Riverpod durum sağlayıcıları.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';

/// Sistemdeki tüm araçların listesini yöneten asenkron durum sağlayıcı.
final vehiclesProvider = AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(() {
  return VehiclesNotifier();
});

/// Araç listesi durumunu yöneten Notifier sınıfı.
class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  /// Başlangıçta tüm araçları repository'den yükler.
  @override
  Future<List<Vehicle>> build() async {
    final repo = ref.watch(vehicleRepositoryProvider);
    return repo.getAllVehicles();
  }

  /// Araç listesini yeniden çekerek durumu günceller.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(vehicleRepositoryProvider);
      return repo.getAllVehicles();
    });
  }

  /// Yeni bir araç ilanı ekler ve listeyi tazeler.
  Future<void> addVehicle(Vehicle vehicle) async {
    final repo = ref.read(vehicleRepositoryProvider);
    await repo.addVehicle(vehicle);
    await refresh();
  }

  /// Bir ilanın yayında olma (aktif/duraklatıldı) durumunu değiştirir.
  Future<void> toggleStatus(String vehicleId, bool activate) async {
    final repo = ref.read(vehicleRepositoryProvider);
    if (activate) {
      await repo.activateVehicle(vehicleId);
    } else {
      await repo.pauseVehicle(vehicleId);
    }
    await refresh();
  }
}

/// En popüler araçları hesaplayıp sunan sağlayıcı.
final popularVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  // Watch vehiclesProvider so when vehicles change, popular list updates automatically
  ref.watch(vehiclesProvider);
  final repo = ref.watch(vehicleRepositoryProvider);
  return repo.getPopularVehicles(limit: 10);
});

/// Giriş yapmış araç sahibinin kendi araçlarını listeleyen sağlayıcı.
final ownerVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  ref.watch(vehiclesProvider);
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return [];
  final repo = ref.watch(vehicleRepositoryProvider);
  return repo.getVehiclesByOwner(user.id);
});

/// Kullanıcının favori araç ID'lerini tutan ve yöneten durum sağlayıcısı.
final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(() {
  return FavoritesNotifier();
});

/// Favori araç durumunu yöneten Notifier sınıfı.
class FavoritesNotifier extends Notifier<Set<String>> {
  /// Başlangıçta kayıtlı favori ID'leri kümesini yükler.
  @override
  Set<String> build() {
    final repo = ref.watch(vehicleRepositoryProvider);
    return Set<String>.from(repo.getFavorites());
  }

  /// Bir aracı favoriye ekler veya favorilerden çıkarır.
  void toggle(String vehicleId) {
    final repo = ref.read(vehicleRepositoryProvider);
    repo.toggleFavorite(vehicleId);
    if (state.contains(vehicleId)) {
      state = {...state}..remove(vehicleId);
    } else {
      state = {...state, vehicleId};
    }
  }
}
