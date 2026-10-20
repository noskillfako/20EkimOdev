import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_store.dart';
import '../domain/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getAllVehicles();
  Future<List<Vehicle>> getPopularVehicles({int limit = 10});
  Future<Vehicle> getVehicleById(String id);
  Future<List<Vehicle>> getVehiclesByOwner(String ownerId);
  Future<Vehicle> addVehicle(Vehicle vehicle);
  Future<Vehicle> updateVehicle(Vehicle vehicle);
  Future<void> pauseVehicle(String id);
  Future<void> activateVehicle(String id);
  Future<void> toggleFavorite(String vehicleId);
  Set<String> getFavorites();
  Map<String, dynamic> getCatalog();
}

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final store = ref.watch(mockStoreProvider);
  return FakeVehicleRepository(store);
});

class FakeVehicleRepository implements VehicleRepository {
  final MockStore _store;

  FakeVehicleRepository(this._store);

  @override
  Future<List<Vehicle>> getAllVehicles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_store.vehicles);
  }

  @override
  Future<List<Vehicle>> getPopularVehicles({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final active = _store.vehicles.where((v) => v.isActive).toList()
      ..sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
    return active.take(limit).toList();
  }

  @override
  Future<Vehicle> getVehicleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final v = _store.vehicles.cast<Vehicle?>().firstWhere(
          (element) => element?.id == id,
          orElse: () => null,
        );
    if (v == null) {
      throw Exception('Araç ilanı bulunamadı.');
    }
    return v;
  }

  @override
  Future<List<Vehicle>> getVehiclesByOwner(String ownerId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _store.vehicles.where((v) => v.ownerId == ownerId).toList();
  }

  @override
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _store.vehicles.insert(0, vehicle);
    _store.recomputeVehicleStats(vehicle.id);
    _store.recomputeUserStats(vehicle.ownerId);
    return vehicle;
  }

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _store.vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index == -1) {
      throw Exception('Araç bulunamadı.');
    }
    _store.vehicles[index] = vehicle;
    _store.recomputeVehicleStats(vehicle.id);
    _store.recomputeUserStats(vehicle.ownerId);
    return vehicle;
  }

  @override
  Future<void> pauseVehicle(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _store.vehicles.indexWhere((v) => v.id == id);
    if (index != -1) {
      _store.vehicles[index] = _store.vehicles[index].copyWith(status: 'paused');
    }
  }

  @override
  Future<void> activateVehicle(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _store.vehicles.indexWhere((v) => v.id == id);
    if (index != -1) {
      _store.vehicles[index] = _store.vehicles[index].copyWith(status: 'active');
    }
  }

  @override
  Future<void> toggleFavorite(String vehicleId) async {
    _store.toggleFavorite(vehicleId);
  }

  @override
  Set<String> getFavorites() {
    return _store.favoriteVehicleIds;
  }

  @override
  Map<String, dynamic> getCatalog() {
    return _store.catalog;
  }
}
