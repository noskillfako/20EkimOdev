import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_store.dart';
import '../domain/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login(String email, String password);
  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String birthDate,
    required String profession,
    required String maritalStatus,
    required String gender,
    required List<String> roles,
  });
  Future<void> logout();
  Future<AppUser?> getCurrentUser(String userId);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final store = ref.watch(mockStoreProvider);
  return FakeAuthRepository(store);
});

class FakeAuthRepository implements AuthRepository {
  final MockStore _store;

  FakeAuthRepository(this._store);

  @override
  Future<AppUser> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final normalizedEmail = email.trim().toLowerCase();
    final user = _store.users.cast<AppUser?>().firstWhere(
          (u) => u?.email.toLowerCase() == normalizedEmail,
          orElse: () => null,
        );

    if (user == null) {
      throw Exception('Bu e-posta adresine ait bir hesap bulunamadı.');
    }

    if (user.password != password) {
      throw Exception('Girdiğiniz şifre hatalı.');
    }

    return user;
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String birthDate,
    required String profession,
    required String maritalStatus,
    required String gender,
    required List<String> roles,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final normalizedEmail = email.trim().toLowerCase();
    final exists = _store.users.any((u) => u.email.toLowerCase() == normalizedEmail);
    if (exists) {
      throw Exception('Bu e-posta adresi zaten kullanımda.');
    }

    final newId = 'usr_${(_store.users.length + 1).toString().padLeft(3, '0')}';
    final activeRole = roles.contains('renter') ? 'renter' : 'owner';

    final newUser = AppUser(
      id: newId,
      email: normalizedEmail,
      name: name.trim(),
      password: password,
      birthDate: birthDate,
      profession: profession,
      maritalStatus: maritalStatus,
      gender: gender,
      phone: phone,
      roles: roles,
      activeRole: activeRole,
      criminalRecordStatus: 'verified',
      renterProfile: roles.contains('renter')
          ? const RenterProfile(rentedCount: 0, ratingAvg: 5.0, ratingCount: 0)
          : null,
      ownerProfile: roles.contains('owner')
          ? const OwnerProfile(listingCount: 0, rentedOutCount: 0, ratingAvg: 5.0, ratingCount: 0)
          : null,
    );

    _store.users.add(newUser);
    return newUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<AppUser?> getCurrentUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _store.users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      return _store.users[index];
    }
    return null;
  }
}
