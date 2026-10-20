/// Dosya: lib/features/auth/data/auth_repository.dart
/// Görev / İşlev: Kimlik doğrulama, kullanıcı girişi, yeni üyelik kaydı, çıkış yapma
/// ve mevcut kullanıcıyı ID ile sorgulama işlemlerini soyutlayan repository arayüzü ve
/// MockStore ile çalışan sahte (fake) implementasyonudur.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_store.dart';
import '../domain/app_user.dart';

/// Kimlik doğrulama işlemleri soyut arayüzü
abstract class AuthRepository {
  /// E-posta ve şifre ile sisteme giriş yapar. Başarılı olursa AppUser döner, hatalıysa Exception fırlatır.
  Future<AppUser> login(String email, String password);

  /// Yeni bir kullanıcı hesabı kaydeder ve veritabanına ekler.
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

  /// Kullanıcı oturumunu sonlandırır.
  Future<void> logout();

  /// Belirtilen kullanıcı ID'sine sahip kullanıcıyı döner, bulunamazsa null döner.
  Future<AppUser?> getCurrentUser(String userId);
}

// AuthRepository sağlayıcısı
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final store = ref.watch(mockStoreProvider);
  return FakeAuthRepository(store);
});

// MockStore üzerinde çalışan sahte kimlik doğrulama deposu
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
