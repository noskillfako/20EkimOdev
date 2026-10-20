import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_store.dart';
import '../../auth/domain/app_user.dart';
import '../../reviews/domain/review.dart';

abstract class UserRepository {
  Future<AppUser> getUserById(String id);
  Future<AppUser> updateProfile(AppUser updatedUser);
  Future<List<Review>> getUserReviews(String userId, String role);
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final store = ref.watch(mockStoreProvider);
  return FakeUserRepository(store);
});

class FakeUserRepository implements UserRepository {
  final MockStore _store;

  FakeUserRepository(this._store);

  @override
  Future<AppUser> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final user = _store.users.cast<AppUser?>().firstWhere(
          (u) => u?.id == id,
          orElse: () => null,
        );
    if (user == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }
    return user;
  }

  @override
  Future<AppUser> updateProfile(AppUser updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _store.users.indexWhere((u) => u.id == updatedUser.id);
    if (index == -1) {
      throw Exception('Kullanıcı bulunamadı.');
    }
    _store.users[index] = updatedUser;
    return updatedUser;
  }

  @override
  Future<List<Review>> getUserReviews(String userId, String role) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _store.reviews
        .where((r) => r.targetId == userId && r.targetRole == role)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
