/// Dosya: lib/features/reviews/domain/review.dart
/// Görev / İşlev: Kullanıcılar ve araçlar için yapılan puan ve yorum değerlendirmelerinin
/// etki alanı veri modelidir (Domain Model).
/// Puanlayan kullanıcı, puanlanan hedef kişi/rol ('owner' veya 'renter'), kullanıcı yıldızı (1-5),
/// araç kondisyon yıldızı, metin yorumu ve değerlendirme tarihini temsil eder.

/// Puan ve yorum değerlendirme modeli
class Review {
  final String id; // Değerlendirmenin benzersiz kimliği (Örn: 'rev_001')
  final String rentalId; // Değerlendirmenin ait olduğu tamamlanmış kiralama kimliği
  final String? vehicleId; // Değerlendirilen araç kimliği (Kiracı aracı puanladıysa dolu)
  final String reviewerId; // Değerlendirmeyi yapan kullanıcının kimliği
  final String targetId; // Puanlanan hedef kullanıcının kimliği
  final String targetRole; // Puanlanan rol ('owner' veya 'renter')
  final int stars; // Kullanıcıya verilen yıldız puanı (1 - 5)
  final int? vehicleStars; // Araca verilen yıldız puanı (1 - 5)
  final String comment; // Kullanıcı yorum metni
  final String createdAt; // Değerlendirmenin yazıldığı tarih (ISO format)

  const Review({
    required this.id,
    required this.rentalId,
    this.vehicleId,
    required this.reviewerId,
    required this.targetId,
    required this.targetRole,
    required this.stars,
    this.vehicleStars,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      rentalId: json['rentalId'] as String,
      vehicleId: json['vehicleId'] as String?,
      reviewerId: json['reviewerId'] as String,
      targetId: json['targetId'] as String,
      targetRole: json['targetRole'] as String,
      stars: (json['stars'] as num).toInt(),
      vehicleStars: (json['vehicleStars'] as num?)?.toInt(),
      comment: (json['comment'] as String?) ?? '',
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rentalId': rentalId,
    'vehicleId': vehicleId,
    'reviewerId': reviewerId,
    'targetId': targetId,
    'targetRole': targetRole,
    'stars': stars,
    'vehicleStars': vehicleStars,
    'comment': comment,
    'createdAt': createdAt,
  };

  Review copyWith({
    String? id,
    String? rentalId,
    String? vehicleId,
    String? reviewerId,
    String? targetId,
    String? targetRole,
    int? stars,
    int? vehicleStars,
    String? comment,
    String? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      rentalId: rentalId ?? this.rentalId,
      vehicleId: vehicleId ?? this.vehicleId,
      reviewerId: reviewerId ?? this.reviewerId,
      targetId: targetId ?? this.targetId,
      targetRole: targetRole ?? this.targetRole,
      stars: stars ?? this.stars,
      vehicleStars: vehicleStars ?? this.vehicleStars,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
