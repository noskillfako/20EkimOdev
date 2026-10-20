class Review {
  final String id;
  final String rentalId;
  final String? vehicleId;
  final String reviewerId;
  final String targetId;
  final String targetRole; // 'owner' or 'renter'
  final int stars;
  final int? vehicleStars;
  final String comment;
  final String createdAt;

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
