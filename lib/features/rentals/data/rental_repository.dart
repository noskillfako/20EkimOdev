import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_store.dart';
import '../domain/rental.dart';

abstract class RentalRepository {
  Future<List<Rental>> getRentalsForRenter(String renterId);
  Future<List<Rental>> getRentalsForOwner(String ownerId);
  Future<Rental> getRentalById(String id);
  Future<Rental> createRental(Rental rental);
  Future<void> confirmDelivery(String rentalId);
  Future<void> confirmReturn(String rentalId);
  Future<void> cancelRental(String rentalId, String reason);
}

final rentalRepositoryProvider = Provider<RentalRepository>((ref) {
  final store = ref.watch(mockStoreProvider);
  return FakeRentalRepository(store);
});

class FakeRentalRepository implements RentalRepository {
  final MockStore _store;

  FakeRentalRepository(this._store);

  @override
  Future<List<Rental>> getRentalsForRenter(String renterId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _store.rentals.where((r) => r.renterId == renterId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Rental>> getRentalsForOwner(String ownerId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _store.rentals.where((r) => r.ownerId == ownerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Rental> getRentalById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final r = _store.rentals.cast<Rental?>().firstWhere(
          (element) => element?.id == id,
          orElse: () => null,
        );
    if (r == null) {
      throw Exception('Kiralama kaydı bulunamadı.');
    }
    return r;
  }

  @override
  Future<Rental> createRental(Rental rental) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _store.rentals.insert(0, rental);
    _store.recomputeVehicleStats(rental.vehicleId);
    _store.recomputeUserStats(rental.renterId);
    _store.recomputeUserStats(rental.ownerId);
    return rental;
  }

  @override
  Future<void> confirmDelivery(String rentalId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _store.rentals.indexWhere((r) => r.id == rentalId);
    if (index != -1) {
      _store.rentals[index] = _store.rentals[index].copyWith(status: 'active');
    }
  }

  @override
  Future<void> confirmReturn(String rentalId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _store.rentals.indexWhere((r) => r.id == rentalId);
    if (index != -1) {
      final updated = _store.rentals[index].copyWith(status: 'completed');
      _store.rentals[index] = updated;
      _store.recomputeVehicleStats(updated.vehicleId);
      _store.recomputeUserStats(updated.renterId);
      _store.recomputeUserStats(updated.ownerId);
    }
  }

  @override
  Future<void> cancelRental(String rentalId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _store.rentals.indexWhere((r) => r.id == rentalId);
    if (index != -1) {
      _store.rentals[index] = _store.rentals[index].copyWith(status: 'cancelled');
    }
  }
}
