/// Dosya: lib/features/chat/domain/chat.dart
/// Görev / İşlev: Uygulama içi mesajlaşma ve kiralama pazarlığı etki alanı modelleridir (Domain Models).
/// Teklif detaylarını temsil eden `Offer`, tekil mesajları temsil eden `Message`
/// ve araç sahibi ile kiracı arasındaki sohbet oturumunu temsil eden `Chat` sınıflarını içerir.

/// Kiralama teklifi modeli (Tarih aralığı, fiyatlandırma ve onay durumu).
class Offer {
  final String startDate; // Kiralama başlangıç tarihi
  final String endDate; // Kiralama bitiş tarihi
  final int dailyPrice; // Günlük teklif edilen ücret
  final int totalPrice; // Toplam teklif tutarı
  final String status; // Teklif durumu: 'pending', 'accepted', 'countered', 'rejected', 'expired'

  const Offer({
    required this.startDate,
    required this.endDate,
    required this.dailyPrice,
    required this.totalPrice,
    required this.status,
  });

  bool get isPending => status == 'pending'; // Teklif onay bekliyor mu
  bool get isAccepted => status == 'accepted'; // Teklif kabul edildi mi
  bool get isRejected => status == 'rejected'; // Teklif reddedildi mi
  bool get isCountered => status == 'countered'; // Karşı teklif yapıldı mı

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      dailyPrice: (json['dailyPrice'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toInt(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'startDate': startDate,
    'endDate': endDate,
    'dailyPrice': dailyPrice,
    'totalPrice': totalPrice,
    'status': status,
  };

  Offer copyWith({
    String? startDate,
    String? endDate,
    int? dailyPrice,
    int? totalPrice,
    String? status,
  }) {
    return Offer(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dailyPrice: dailyPrice ?? this.dailyPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String type; // 'text', 'offer', 'system'
  final String text;
  final Offer? offer;
  final String createdAt;
  final bool read;

  const Message({
    required this.id,
    required this.senderId,
    required this.type,
    required this.text,
    this.offer,
    required this.createdAt,
    this.read = false,
  });

  bool get isOffer => type == 'offer' && offer != null;
  bool get isSystem => type == 'system';
  bool get isText => type == 'text';

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      type: json['type'] as String,
      text: json['text'] as String,
      offer: json['offer'] != null
          ? Offer.fromJson(json['offer'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String,
      read: (json['read'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'type': type,
    'text': text,
    'offer': offer?.toJson(),
    'createdAt': createdAt,
    'read': read,
  };

  Message copyWith({
    String? id,
    String? senderId,
    String? type,
    String? text,
    Offer? offer,
    String? createdAt,
    bool? read,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      text: text ?? this.text,
      offer: offer ?? this.offer,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}

class Chat {
  final String id;
  final String vehicleId;
  final String ownerId;
  final String renterId;
  final String lastMessage;
  final int unreadCount;
  final String updatedAt;
  final List<Message> messages;

  const Chat({
    required this.id,
    required this.vehicleId,
    required this.ownerId,
    required this.renterId,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
    required this.messages,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      ownerId: json['ownerId'] as String,
      renterId: json['renterId'] as String,
      lastMessage: json['lastMessage'] as String,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] as String,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'ownerId': ownerId,
    'renterId': renterId,
    'lastMessage': lastMessage,
    'unreadCount': unreadCount,
    'updatedAt': updatedAt,
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  Chat copyWith({
    String? id,
    String? vehicleId,
    String? ownerId,
    String? renterId,
    String? lastMessage,
    int? unreadCount,
    String? updatedAt,
    List<Message>? messages,
  }) {
    return Chat(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      ownerId: ownerId ?? this.ownerId,
      renterId: renterId ?? this.renterId,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }
}
