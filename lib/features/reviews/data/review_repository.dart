import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_store.dart';
import '../domain/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviewsForVehicle(String vehicleId);
  Future<List<Review>> getReviewsForUser(String userId, String role);
  Future<bool> hasReviewedRental(String rentalId, String reviewerId);
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

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final store = ref.watch(mockStoreProvider);
  return FakeReviewRepository(store);
});

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
