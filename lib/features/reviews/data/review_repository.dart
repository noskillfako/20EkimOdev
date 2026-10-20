/// Dosya: lib/features/reviews/data/review_repository.dart
/// Görev / İşlev: Araçlara ve kullanıcılara (Kiracı veya Araç Sahibi) yapılan değerlendirmeleri
/// getirme, bir kiralamanın daha önce puanlanıp puanlanmadığını denetleme ve yeni değerlendirme
/// ekleyip ortalama istatistikleri baştan hesaplama veri işlemlerini yönetir.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_store.dart';
import '../domain/review.dart';

/// Değerlendirme veri işlemleri soyut arayüzü
abstract class ReviewRepository {
  /// Belirli bir araca yapılmış tüm değerlendirmeleri ve araç yıldızlarını döner.
  Future<List<Review>> getReviewsForVehicle(String vehicleId);

  /// Belirli bir kullanıcıya (kiracı veya sahip rolünde) yapılmış değerlendirmeleri döner.
  Future<List<Review>> getReviewsForUser(String userId, String role);

  /// Kullanıcının bu kiralama için daha önce puanlama yapıp yapmadığını kontrol eder.
  Future<bool> hasReviewedRental(String rentalId, String reviewerId);

  /// Yeni bir puanlama ve yorum kaydeder; aracın ve hedefin puan ortalamalarını günceller.
  Future<Review> addReview({
    required String rentalId,
    required String? vehicleId,
    required String reviewerId,
    required String targetId,
    required String targetRole,
    required int stars,
    int? vehicleStars,
    required String comment,
  });
}

// ReviewRepository sağlayıcısı
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final store = ref.watch(mockStoreProvider);
  return FakeReviewRepository(store);
});

// MockStore üzerinde çalışan sahte değerlendirme deposu
class FakeReviewRepository implements ReviewRepository {
  final MockStore _store;

  FakeReviewRepository(this._store);

  @override
  Future<List<Review>> getReviewsForVehicle(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.reviews
        .where((r) => r.vehicleId == vehicleId && r.vehicleStars != null)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Review>> getReviewsForUser(String userId, String role) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.reviews
        .where((r) => r.targetId == userId && r.targetRole == role)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<bool> hasReviewedRental(String rentalId, String reviewerId) async {
    return _store.reviews.any((r) => r.rentalId == rentalId && r.reviewerId == reviewerId);
  }

  @override
  Future<Review> addReview({
    required String rentalId,
    required String? vehicleId,
    required String reviewerId,
    required String targetId,
    required String targetRole,
    required int stars,
    int? vehicleStars,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Check if already reviewed
    final already = _store.reviews.any((r) => r.rentalId == rentalId && r.reviewerId == reviewerId);
    if (already) {
      throw Exception('Bu kiralama için daha önce değerlendirme yaptınız.');
    }

    final newReview = Review(
      id: 'rev_${(_store.reviews.length + 1).toString().padLeft(3, '0')}',
      rentalId: rentalId,
      vehicleId: vehicleId,
      reviewerId: reviewerId,
      targetId: targetId,
      targetRole: targetRole,
      stars: stars,
      vehicleStars: vehicleStars,
      comment: comment.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    _store.reviews.insert(0, newReview);

    // Recalculate vehicle and target user stats immediately
    if (vehicleId != null) {
      _store.recomputeVehicleStats(vehicleId);
    }
    _store.recomputeUserStats(targetId);

    return newReview;
  }
}
