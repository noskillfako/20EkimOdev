import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';

final vehiclesProvider = AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(() {
  return VehiclesNotifier();
});

class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    final repo = ref.watch(vehicleRepositoryProvider);
    return repo.getAllVehicles();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(vehicleRepositoryProvider);
      return repo.getAllVehicles();
    });
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final repo = ref.read(vehicleRepositoryProvider);
    await repo.addVehicle(vehicle);
    await refresh();
  }

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

final popularVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  // Watch vehiclesProvider so when vehicles change, popular list updates automatically
  ref.watch(vehiclesProvider);
  final repo = ref.watch(vehicleRepositoryProvider);
  return repo.getPopularVehicles(limit: 10);
});

final ownerVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  ref.watch(vehiclesProvider);
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return [];
  final repo = ref.watch(vehicleRepositoryProvider);
  return repo.getVehiclesByOwner(user.id);
});

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(() {
  return FavoritesNotifier();
});

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final repo = ref.watch(vehicleRepositoryProvider);
    return Set<String>.from(repo.getFavorites());
  }

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
