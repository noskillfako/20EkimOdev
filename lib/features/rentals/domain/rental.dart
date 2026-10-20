/// Dosya: lib/features/rentals/domain/rental.dart
/// Görev / İşlev: Araç kiralama ve rezervasyon işlemlerinin etki alanı veri modelidir (Domain Model).
/// Kiralanan araç, araç sahibi, kiracı kimlikleri, kiralama tarihleri, günlük ve toplam fiyat,
/// depozito teminatı, kiralama aşama durumu ('active', 'completed', 'pending_confirmation', 'cancelled')
/// ve oluşturulma zamanını temsil eder.

/// Araç kiralama ve sözleşme kaydı modeli
class Rental {
  final String id; // Kiralama benzersiz kimliği (Örn: 'rent_001')
  final String vehicleId; // Kiralanan aracın kimliği
  final String ownerId; // Araç sahibinin kullanıcı kimliği
  final String renterId; // Aracı kiralayan kiracının kullanıcı kimliği
  final String startDate; // Kiralama başlangıç tarihi (ISO format)
  final String endDate; // Kiralama bitiş / teslim tarihi (ISO format)
  final int dailyPrice; // Günlük anlaşılan kiralama ücreti
  final int totalDays; // Toplam kiralanan gün sayısı
  final int totalPrice; // Toplam kiralama bedeli
  final int deposit; // Alınan güvence teminatı (depozito) bedeli
  final String status; // Durum: 'pending_confirmation', 'active', 'completed', 'cancelled'
  final String createdAt; // Kiralama kaydının oluşturulma tarihi

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

  bool get isCompleted => status == 'completed'; // Kiralama süreci başarıyla tamamlandı mı
  bool get isActive => status == 'active'; // Araç şu anda kirada / kullanımda mı
  bool get isPending => status == 'pending_confirmation'; // Onay aşamasında mı
  bool get isCancelled => status == 'cancelled'; // Kiralama iptal edildi mi

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
