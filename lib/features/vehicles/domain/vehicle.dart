// Araç etki alanı veri modeli (Domain Model)
// Sistemdeki araçların teknik özellikleri, fiyatı, konumu, popülerlik skoru ve durumunu temsil eder
class Vehicle {
  final String id; // Aracın benzersiz kimliği (Örn: 'veh_001')
  final String ownerId; // Aracı sisteme ekleyen araç sahibinin kullanıcı kimliği
  final String brand; // Araç markası (Örn: 'Fiat', 'Renault', 'Volkswagen')
  final String model; // Araç modeli (Örn: 'Egea', 'Clio', 'Passat')
  final int modelYear; // Model yılı (Örn: 2023)
  final int km; // Mevcut kilometre (Örn: 45000)
  final String fuelType; // Yakıt türü ('benzin', 'dizel', 'hibrit', 'elektrik')
  final String bodyType; // Kasa tipi ('sedan', 'hatchback', 'suv', 'station')
  final String transmission; // Vites türü ('otomatik', 'manuel')
  final String color; // Araç rengi (Örn: 'Beyaz', 'Siyah', 'Kırmızı')
  final int? engineCc; // Motor silindir hacmi cc cinsinden (Örn: 1400)
  final int widthMm; // Araç genişliği milimetre cinsinden (Örn: 1792)
  final int weightKg; // Araç boş ağırlığı kg cinsinden (Örn: 1250)
  final int seats; // Koltuk / Yolcu kapasitesi (Örn: 5)
  final double? fuelConsumption; // 100 km'de ortalama yakıt tüketimi litre cinsinden (Örn: 5.4)
  final int dailyPrice; // Günlük kiralama bedeli TL cinsinden (Örn: 1250)
  final int deposit; // Güvence teminatı / depozito bedeli TL cinsinden (Örn: 3000)
  final int dailyKmLimit; // Günlük izin verilen kilometre sınırı (Örn: 300)
  final int minRentalDays; // Minimum kiralama süresi (gün)
  final int maxRentalDays; // Maksimum kiralama süresi (gün)
  final String city; // Aracın bulunduğu şehir (Örn: 'İstanbul', 'Ankara')
  final double lat; // Coğrafi enlem koordinatı
  final double lng; // Coğrafi boylam koordinatı
  final List<String> photos; // Araç fotoğraflarının dosya yolları listesi
  final String status; // İlan durumu: 'active' (yayında), 'rented' (kirada), 'paused' (duraklatıldı), 'draft' (taslak)
  final String description; // Araç hakkında açıklama ve kiralama şartları
  final int uniqueRenterCount; // Aracı kiralayan farklı kiracı sayısı (Matematiksel popülerlik için)
  final int completedRentalCount; // Araç ile başarıyla tamamlanan kiralama sayısı
  final double ratingAvg; // Araç için verilen ortalama kullanıcı puanı (1.0 - 5.0)
  final int ratingCount; // Araca yapılan değerlendirme sayısı
  final double popularityScore; // Sıralamada kullanılan bileşik popülerlik skoru

  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.modelYear,
    required this.km,
    required this.fuelType,
    required this.bodyType,
    required this.transmission,
    required this.color,
    this.engineCc,
    required this.widthMm,
    required this.weightKg,
    required this.seats,
    this.fuelConsumption,
    required this.dailyPrice,
    required this.deposit,
    required this.dailyKmLimit,
    required this.minRentalDays,
    required this.maxRentalDays,
    required this.city,
    required this.lat,
    required this.lng,
    required this.photos,
    required this.status,
    required this.description,
    this.uniqueRenterCount = 0,
    this.completedRentalCount = 0,
    this.ratingAvg = 5.0,
    this.ratingCount = 0,
    this.popularityScore = 0.0,
  });

  // Araç başlığı türetimi: Marka + Model (Örn: "Fiat Egea")
  String get title => '$brand $model';
  // Araç yaşı hesabı: Güncel yıl - Model yılı
  int get age => DateTime.now().year - modelYear;
  // İlan yayında mı?
  bool get isActive => status == 'active';
  // İlan duraklatılmış mı?
  bool get isPaused => status == 'paused';
  // Araç şu an kiralanmış durumda mı?
  bool get isRented => status == 'rented';

  // JSON haritasından Araç nesnesi oluşturan kurucu metot
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      modelYear: (json['modelYear'] as num).toInt(),
      km: (json['km'] as num).toInt(),
      fuelType: json['fuelType'] as String,
      bodyType: json['bodyType'] as String,
      transmission: json['transmission'] as String,
      color: json['color'] as String,
      engineCc: (json['engineCc'] as num?)?.toInt(),
      widthMm: (json['widthMm'] as num).toInt(),
      weightKg: (json['weightKg'] as num).toInt(),
      seats: (json['seats'] as num).toInt(),
      fuelConsumption: (json['fuelConsumption'] as num?)?.toDouble(),
      dailyPrice: (json['dailyPrice'] as num).toInt(),
      deposit: (json['deposit'] as num).toInt(),
      dailyKmLimit: (json['dailyKmLimit'] as num).toInt(),
      minRentalDays: (json['minRentalDays'] as num).toInt(),
      maxRentalDays: (json['maxRentalDays'] as num).toInt(),
      city: json['city'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      photos: (json['photos'] as List<dynamic>).map((e) => e.toString()).toList(),
      status: json['status'] as String,
      description: json['description'] as String,
      uniqueRenterCount: (json['uniqueRenterCount'] as num?)?.toInt() ?? 0,
      completedRentalCount: (json['completedRentalCount'] as num?)?.toInt() ?? 0,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 5.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      popularityScore: (json['popularityScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Araç nesnesini JSON formatına dönüştüren metot
  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'brand': brand,
    'model': model,
    'modelYear': modelYear,
    'km': km,
    'fuelType': fuelType,
    'bodyType': bodyType,
    'transmission': transmission,
    'color': color,
    'engineCc': engineCc,
    'widthMm': widthMm,
    'weightKg': weightKg,
    'seats': seats,
    'fuelConsumption': fuelConsumption,
    'dailyPrice': dailyPrice,
    'deposit': deposit,
    'dailyKmLimit': dailyKmLimit,
    'minRentalDays': minRentalDays,
    'maxRentalDays': maxRentalDays,
    'city': city,
    'lat': lat,
    'lng': lng,
    'photos': photos,
    'status': status,
    'description': description,
    'uniqueRenterCount': uniqueRenterCount,
    'completedRentalCount': completedRentalCount,
    'ratingAvg': ratingAvg,
    'ratingCount': ratingCount,
    'popularityScore': popularityScore,
  };

  // Mevcut araç nesnesini değişen alanlarla kopyalama (Immutability pattern)
  Vehicle copyWith({
    String? id,
    String? ownerId,
    String? brand,
    String? model,
    int? modelYear,
    int? km,
    String? fuelType,
    String? bodyType,
    String? transmission,
    String? color,
    int? engineCc,
    int? widthMm,
    int? weightKg,
    int? seats,
    double? fuelConsumption,
    int? dailyPrice,
    int? deposit,
    int? dailyKmLimit,
    int? minRentalDays,
    int? maxRentalDays,
    String? city,
    double? lat,
    double? lng,
    List<String>? photos,
    String? status,
    String? description,
    int? uniqueRenterCount,
    int? completedRentalCount,
    double? ratingAvg,
    int? ratingCount,
    double? popularityScore,
  }) {
    return Vehicle(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      modelYear: modelYear ?? this.modelYear,
      km: km ?? this.km,
      fuelType: fuelType ?? this.fuelType,
      bodyType: bodyType ?? this.bodyType,
      transmission: transmission ?? this.transmission,
      color: color ?? this.color,
      engineCc: engineCc ?? this.engineCc,
      widthMm: widthMm ?? this.widthMm,
      weightKg: weightKg ?? this.weightKg,
      seats: seats ?? this.seats,
      fuelConsumption: fuelConsumption ?? this.fuelConsumption,
      dailyPrice: dailyPrice ?? this.dailyPrice,
      deposit: deposit ?? this.deposit,
      dailyKmLimit: dailyKmLimit ?? this.dailyKmLimit,
      minRentalDays: minRentalDays ?? this.minRentalDays,
      maxRentalDays: maxRentalDays ?? this.maxRentalDays,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      description: description ?? this.description,
      uniqueRenterCount: uniqueRenterCount ?? this.uniqueRenterCount,
      completedRentalCount: completedRentalCount ?? this.completedRentalCount,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      popularityScore: popularityScore ?? this.popularityScore,
    );
  }
}
