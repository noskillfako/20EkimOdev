import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/rental_repository.dart';
import '../domain/rental.dart';

final renterRentalsProvider = AsyncNotifierProvider<RenterRentalsNotifier, List<Rental>>(() {
  return RenterRentalsNotifier();
});

class RenterRentalsNotifier extends AsyncNotifier<List<Rental>> {
  @override
  Future<List<Rental>> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return [];
    final repo = ref.watch(rentalRepositoryProvider);
    return repo.getRentalsForRenter(user.id);
  }

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

final ownerRentalsProvider = AsyncNotifierProvider<OwnerRentalsNotifier, List<Rental>>(() {
  return OwnerRentalsNotifier();
});

class OwnerRentalsNotifier extends AsyncNotifier<List<Rental>> {
  @override
  Future<List<Rental>> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return [];
    final repo = ref.watch(rentalRepositoryProvider);
    return repo.getRentalsForOwner(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authControllerProvider).value;
      if (user == null) return [];
      final repo = ref.read(rentalRepositoryProvider);
      return repo.getRentalsForOwner(user.id);
    });
  }

  Future<void> confirmDelivery(String rentalId) async {
    final repo = ref.read(rentalRepositoryProvider);
    await repo.confirmDelivery(rentalId);
    await refresh();
  }

  Future<void> confirmReturn(String rentalId) async {
    final repo = ref.read(rentalRepositoryProvider);
    await repo.confirmReturn(rentalId);
    await refresh();
  }

  Future<void> cancelRental(String rentalId, String reason) async {
    final repo = ref.read(rentalRepositoryProvider);
    await repo.cancelRental(rentalId, reason);
    await refresh();
  }
}
