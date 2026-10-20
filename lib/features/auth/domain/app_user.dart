// Kiracı profil alt modeli (Kiralanan araç sayısı ve kiracı değerlendirme puanları)
class RenterProfile {
  final int rentedCount; // Kullanıcının şimdiye kadar kiraladığı araç sayısı
  final double ratingAvg; // Araç sahiplerinden aldığı ortalama puan (1.0 - 5.0)
  final int ratingCount; // Yapılan değerlendirme sayısı

  const RenterProfile({
    required this.rentedCount,
    required this.ratingAvg,
    required this.ratingCount,
  });

  // JSON haritasından RenterProfile nesnesi üretir
  factory RenterProfile.fromJson(Map<String, dynamic> json) {
    return RenterProfile(
      rentedCount: (json['rentedCount'] as num?)?.toInt() ?? 0,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 5.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }

  // JSON formatına dönüştürür
  Map<String, dynamic> toJson() => {
    'rentedCount': rentedCount,
    'ratingAvg': ratingAvg,
    'ratingCount': ratingCount,
  };

  // Kopyalama fonksiyonu
  RenterProfile copyWith({
    int? rentedCount,
    double? ratingAvg,
    int? ratingCount,
  }) {
    return RenterProfile(
      rentedCount: rentedCount ?? this.rentedCount,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}

// Araç Sahibi profil alt modeli (İlan sayısı, kiralattığı araç sayısı ve sahip puanı)
class OwnerProfile {
  final int listingCount; // Yayındaki toplam araç ilanı sayısı
  final int rentedOutCount; // Başarıyla kiralattığı toplam işlem sayısı
  final double ratingAvg; // Kiracılardan aldığı ortalama puan (1.0 - 5.0)
  final int ratingCount; // Yapılan değerlendirme sayısı

  const OwnerProfile({
    required this.listingCount,
    required this.rentedOutCount,
    required this.ratingAvg,
    required this.ratingCount,
  });

  // JSON haritasından OwnerProfile nesnesi üretir
  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    return OwnerProfile(
      listingCount: (json['listingCount'] as num?)?.toInt() ?? 0,
      rentedOutCount: (json['rentedOutCount'] as num?)?.toInt() ?? 0,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 5.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }

  // JSON formatına dönüştürür
  Map<String, dynamic> toJson() => {
    'listingCount': listingCount,
    'rentedOutCount': rentedOutCount,
    'ratingAvg': ratingAvg,
    'ratingCount': ratingCount,
  };

  // Kopyalama fonksiyonu
  OwnerProfile copyWith({
    int? listingCount,
    int? rentedOutCount,
    double? ratingAvg,
    int? ratingCount,
  }) {
    return OwnerProfile(
      listingCount: listingCount ?? this.listingCount,
      rentedOutCount: rentedOutCount ?? this.rentedOutCount,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}

// Ana Kullanıcı Modeli (Çift rol destekli, tek hesap altında Kiracı ve Araç Sahibi yönetimi)
class AppUser {
  final String id; // Kullanıcı benzersiz kimliği (Örn: 'usr_001')
  final String email; // Giriş e-posta adresi
  final String name; // Ad Soyad
  final String password; // Şifre
  final String birthDate; // Doğum tarihi (ISO string, yaş hesabı için)
  final String profession; // Meslek (Güven ve profil için)
  final String maritalStatus; // Medeni durum ('Evli', 'Bekar')
  final String gender; // Cinsiyet
  final String phone; // İletişim telefonu
  final List<String> roles; // Sahip olduğu roller: ['renter'], ['owner'] veya ['renter', 'owner']
  final String activeRole; // Şu an aktif kullanılan arayüz rolü ('renter' veya 'owner')
  final String criminalRecordStatus; // Adli sicil kaydı durumu: 'verified' (onaylı) veya 'none'
  final String? avatarUrl; // Profil resmi bağlantısı
  final RenterProfile? renterProfile; // Kiracı rolüne ait istatistik verileri
  final OwnerProfile? ownerProfile; // Araç Sahibi rolüne ait istatistik verileri

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    required this.birthDate,
    required this.profession,
    required this.maritalStatus,
    required this.gender,
    required this.phone,
    required this.roles,
    required this.activeRole,
    this.criminalRecordStatus = 'none',
    this.avatarUrl,
    this.renterProfile,
    this.ownerProfile,
  });

  // Kullanıcı Araç Sahibi rolüne sahip mi?
  bool get isOwner => roles.contains('owner');
  // Kullanıcı Kiracı rolüne sahip mi?
  bool get isRenter => roles.contains('renter');
  // Kullanıcı her iki role de aynı anda sahip mi? (Çift Rol)
  bool get hasBothRoles => isOwner && isRenter;
  // Kullanıcının adli sicil kaydı onaylanmış ve doğrulanmış mı?
  bool get isCriminalRecordVerified => criminalRecordStatus == 'verified';

  // JSON haritasından AppUser nesnesi üretir
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      password: (json['password'] as String?) ?? 'password123',
      birthDate: json['birthDate'] as String,
      profession: (json['profession'] as String?) ?? 'Serbest Meslek',
      maritalStatus: (json['maritalStatus'] as String?) ?? 'Bekar',
      gender: (json['gender'] as String?) ?? 'Erkek',
      phone: (json['phone'] as String?) ?? '+90 555 000 0000',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['renter'],
      activeRole: (json['activeRole'] as String?) ?? 'renter',
      criminalRecordStatus: (json['criminalRecordStatus'] as String?) ?? 'none',
      avatarUrl: json['avatarUrl'] as String?,
      renterProfile: json['renterProfile'] != null
          ? RenterProfile.fromJson(json['renterProfile'] as Map<String, dynamic>)
          : null,
      ownerProfile: json['ownerProfile'] != null
          ? OwnerProfile.fromJson(json['ownerProfile'] as Map<String, dynamic>)
          : null,
    );
  }

  // AppUser nesnesini JSON haritasına dönüştürür
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'password': password,
    'birthDate': birthDate,
    'profession': profession,
    'maritalStatus': maritalStatus,
    'gender': gender,
    'phone': phone,
    'roles': roles,
    'activeRole': activeRole,
    'criminalRecordStatus': criminalRecordStatus,
    'avatarUrl': avatarUrl,
    'renterProfile': renterProfile?.toJson(),
    'ownerProfile': ownerProfile?.toJson(),
  };

  // Mevcut kullanıcıyı güncellenmiş alanlarla kopyalama metodu (Immutability)
  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? password,
    String? birthDate,
    String? profession,
    String? maritalStatus,
    String? gender,
    String? phone,
    List<String>? roles,
    String? activeRole,
    String? criminalRecordStatus,
    String? avatarUrl,
    RenterProfile? renterProfile,
    OwnerProfile? ownerProfile,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      birthDate: birthDate ?? this.birthDate,
      profession: profession ?? this.profession,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      roles: roles ?? this.roles,
      activeRole: activeRole ?? this.activeRole,
      criminalRecordStatus: criminalRecordStatus ?? this.criminalRecordStatus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      renterProfile: renterProfile ?? this.renterProfile,
      ownerProfile: ownerProfile ?? this.ownerProfile,
    );
  }
}
