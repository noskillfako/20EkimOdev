/// Dosya: lib/features/rentals/presentation/rental_providers.dart
/// Görev / İşlev: Kiracının kiralama kayıtlarını (`renterRentalsProvider`) ve
/// araç sahibinin kiralamalarını (`ownerRentalsProvider`) Riverpod ile yönetir;
/// araç teslim alma, iade alma ve iptal işlemlerini koordine eder.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/rental_repository.dart';
import '../domain/rental.dart';

// Kiracının kiraladığı araçların listesini sağlayan NotifierProvider
final renterRentalsProvider = AsyncNotifierProvider<RenterRentalsNotifier, List<Rental>>(() {
  return RenterRentalsNotifier();
});

// Kiracı kiralama listesi durum denetleyicisi
class RenterRentalsNotifier extends AsyncNotifier<List<Rental>> {
  /// Giriş yapmış kiracının tüm kiralama kayıtlarını asenkron olarak çeker.
  @override
  Future<List<Rental>> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return [];
    final repo = ref.watch(rentalRepositoryProvider);
    return repo.getRentalsForRenter(user.id);
  }

  /// Kiracının kiralama listesini depodan yeniden çekip arayüzü günceller.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authControllerProvider).value;
      if (user == null) return [];
      final repo = ref.read(rentalRepositoryProvider);
      return repo.getRentalsForRenter(user.id);
    });
  }
}

// Araç sahibinin kiralama geçmişi ve gelen kiralama taleplerini sağlayan NotifierProvider
final ownerRentalsProvider = AsyncNotifierProvider<OwnerRentalsNotifier, List<Rental>>(() {
  return OwnerRentalsNotifier();
});

// Araç sahibi kiralama listesi ve kiralama durumu aksiyonlarını yöneten sınıf
class OwnerRentalsNotifier extends AsyncNotifier<List<Rental>> {
  /// Giriş yapmış araç sahibinin kiralama işlemlerini asenkron olarak çeker.
  @override
  Future<List<Rental>> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return [];
    final repo = ref.watch(rentalRepositoryProvider);
    return repo.getRentalsForOwner(user.id);
  }

  /// Araç sahibinin kiralama listesini günceller.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authControllerProvider).value;
      if (user == null) return [];
      final repo = ref.read(rentalRepositoryProvider);
      return repo.getRentalsForOwner(user.id);
    });
  }

  /// Aracın kiracıya teslim edildiğini onaylar (Durum 'active' olur).
  Future<void> confirmDelivery(String rentalId) async {
    final repo = ref.read(rentalRepositoryProvider);
    await repo.confirmDelivery(rentalId);
    await refresh();
  }

  /// Aracın kiracıdan teslim alındığını/iade edildiğini onaylar (Durum 'completed' olur).
  Future<void> confirmReturn(String rentalId) async {
    final repo = ref.read(rentalRepositoryProvider);
    await repo.confirmReturn(rentalId);
    await refresh();
  }

  /// Kiralamayı belirtilen sebeple iptal eder.
  Future<void> cancelRental(String rentalId, String reason) async {
    final repo = ref.read(rentalRepositoryProvider);
    await repo.cancelRental(rentalId, reason);
    await refresh();
  }
}

