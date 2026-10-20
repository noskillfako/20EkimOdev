/// Dosya: lib/features/rentals/data/rental_repository.dart
/// Görev / İşlev: Kiralama kayıtlarının oluşturulması, kiracı ve araç sahibine göre listelenmesi,
/// teslim alma (confirmDelivery), iade alma (confirmReturn) ve iptal işlemlerini yöneten
/// veri erişim deposudur (Repository).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_store.dart';
import '../domain/rental.dart';

/// Kiralama işlemleri soyut arayüzü
abstract class RentalRepository {
  /// Kiracının yaptığı tüm kiralama işlemlerini döner.
  Future<List<Rental>> getRentalsForRenter(String renterId);

  /// Araç sahibinin kiralattığı tüm araçların kiralama kayıtlarını döner.
  Future<List<Rental>> getRentalsForOwner(String ownerId);

  /// Kiralama kimliğine (id) göre tek bir kaydı getirir.
  Future<Rental> getRentalById(String id);

  /// Yeni bir kiralama kaydı oluşturur ve istatistikleri günceller.
  Future<Rental> createRental(Rental rental);

  /// Araç teslim alındığında kiralama durumunu 'active' yapar.
  Future<void> confirmDelivery(String rentalId);

  /// Araç iade edildiğinde kiralama durumunu 'completed' yapar ve tamamlanma istatistiklerini hesaplar.
  Future<void> confirmReturn(String rentalId);

  /// Belirtilen gerekçeyle kiralamayı iptal eder.
  Future<void> cancelRental(String rentalId, String reason);
}

// RentalRepository sağlayıcısı
final rentalRepositoryProvider = Provider<RentalRepository>((ref) {
  final store = ref.watch(mockStoreProvider);
  return FakeRentalRepository(store);
});

// MockStore üzerinde çalışan sahte kiralama deposu
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
