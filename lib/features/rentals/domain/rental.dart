class Rental {
  final String id;
  final String vehicleId;
  final String ownerId;
  final String renterId;
  final String startDate;
  final String endDate;
  final int dailyPrice;
  final int totalDays;
  final int totalPrice;
  final int deposit;
  final String status; // 'pending_confirmation', 'active', 'completed', 'cancelled'
  final String createdAt;

  const Rental({
    required this.id,
    required this.vehicleId,
    required this.ownerId,
    required this.renterId,
    required this.startDate,
    required this.endDate,
    required this.dailyPrice,
    required this.totalDays,
    required this.totalPrice,
    required this.deposit,
    required this.status,
    required this.createdAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending_confirmation';
  bool get isCancelled => status == 'cancelled';

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      ownerId: json['ownerId'] as String,
      renterId: json['renterId'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      dailyPrice: (json['dailyPrice'] as num).toInt(),
      totalDays: (json['totalDays'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toInt(),
      deposit: (json['deposit'] as num).toInt(),
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'ownerId': ownerId,
    'renterId': renterId,
    'startDate': startDate,
    'endDate': endDate,
    'dailyPrice': dailyPrice,
    'totalDays': totalDays,
    'totalPrice': totalPrice,
    'deposit': deposit,
    'status': status,
    'createdAt': createdAt,
  };

  Rental copyWith({
    String? id,
    String? vehicleId,
    String? ownerId,
    String? renterId,
    String? startDate,
    String? endDate,
    int? dailyPrice,
    int? totalDays,
    int? totalPrice,
    int? deposit,
    String? status,
    String? createdAt,
  }) {
    return Rental(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      ownerId: ownerId ?? this.ownerId,
      renterId: renterId ?? this.renterId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dailyPrice: dailyPrice ?? this.dailyPrice,
      totalDays: totalDays ?? this.totalDays,
      totalPrice: totalPrice ?? this.totalPrice,
      deposit: deposit ?? this.deposit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
