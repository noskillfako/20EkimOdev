/// Dosya: lib/features/profile/data/user_repository.dart
/// Görev / İşlev: Kullanıcı profili bilgilerini getirme, profil güncelleme (ad, telefon, meslek vb.)
/// ve kullanıcının geçmiş değerlendirmelerini (reviews) listeleme veri işlemlerini yöneten repository sınıfıdır.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_store.dart';
import '../../auth/domain/app_user.dart';
import '../../reviews/domain/review.dart';

/// Kullanıcı veri işlemleri soyut arayüzü
abstract class UserRepository {
  /// Belirtilen kullanıcı ID'sine sahip kullanıcının güncel profilini döner.
  Future<AppUser> getUserById(String id);

  /// Güncellenmiş profil bilgilerini veritabanına kaydeder ve yeni kullanıcı nesnesini döner.
  Future<AppUser> updateProfile(AppUser updatedUser);

  /// Kullanıcının kiracı veya araç sahibi rolüne ait aldığı tüm değerlendirmeleri tarihe göre sıralı döner.
  Future<List<Review>> getUserReviews(String userId, String role);
}

// UserRepository sağlayıcısı
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final store = ref.watch(mockStoreProvider);
  return FakeUserRepository(store);
});

// MockStore üzerinde çalışan sahte kullanıcı deposu
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
