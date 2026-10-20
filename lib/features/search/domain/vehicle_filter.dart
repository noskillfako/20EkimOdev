/// Dosya: lib/features/search/domain/vehicle_filter.dart
/// Görev / İşlev: Araç arama ve filtreleme kriterlerini (fiyat, yaş, km, konum, marka, yakıt, sıralama vb.)
/// modelleyen ve verilen araç listesine bu filtreleri uygulayıp sıralayan filtre sınıfı.
import '../../../core/utils/haversine.dart';
import '../../vehicles/domain/vehicle.dart';

/// Araç filtreleme ve sıralama parametrelerini tutan domain modeli.
class VehicleFilter {
  final double? minAge;
  final double? maxAge;
  final double? minPrice;
  final double? maxPrice;
  final double? minKm;
  final double? maxKm;
  final String? centerCity;
  final double? centerLat;
  final double? centerLng;
  final double? radiusKm;
  final List<String>? brands;
  final List<String>? models;
  final List<String>? fuelTypes;
  final List<String>? bodyTypes;
  final List<String>? transmissions;
  final int? minCompletedRentals;
  final double? maxConsumption;
  final List<String>? colors;
  final int? minEngineCc;
  final int? maxEngineCc;
  final int? minWidthMm;
  final int? maxWidthMm;
  final int? minWeightKg;
  final int? maxWeightKg;
  final int? minUniqueRenters;
  final int? seats;
  final double? minOwnerRating;
  final String sortBy; // 'recommended', 'price_asc', 'price_desc', 'newest', 'rating', 'popularity'
  final String? query;

  /// Filtre nesnesi kurucusu.
  const VehicleFilter({
    this.minAge,
    this.maxAge,
    this.minPrice,
    this.maxPrice,
    this.minKm,
    this.maxKm,
    this.centerCity,
    this.centerLat,
    this.centerLng,
    this.radiusKm,
    this.brands,
    this.models,
    this.fuelTypes,
    this.bodyTypes,
    this.transmissions,
    this.minCompletedRentals,
    this.maxConsumption,
    this.colors,
    this.minEngineCc,
    this.maxEngineCc,
    this.minWidthMm,
    this.maxWidthMm,
    this.minWeightKg,
    this.maxWeightKg,
    this.minUniqueRenters,
    this.seats,
    this.minOwnerRating,
    this.sortBy = 'recommended',
    this.query,
  });

  /// Herhangi bir aktif filtre kriteri seçilmiş mi kontrol eder.
  bool get hasActiveFilters {
    return minAge != null ||
        maxAge != null ||
        minPrice != null ||
        maxPrice != null ||
        minKm != null ||
        maxKm != null ||
        (centerCity != null && radiusKm != null) ||
        (brands != null && brands!.isNotEmpty) ||
        (models != null && models!.isNotEmpty) ||
        (fuelTypes != null && fuelTypes!.isNotEmpty) ||
        (bodyTypes != null && bodyTypes!.isNotEmpty) ||
        (transmissions != null && transmissions!.isNotEmpty) ||
        minCompletedRentals != null ||
        maxConsumption != null ||
        (colors != null && colors!.isNotEmpty) ||
        minEngineCc != null ||
        maxEngineCc != null ||
        minWidthMm != null ||
        maxWidthMm != null ||
        minWeightKg != null ||
        maxWeightKg != null ||
        minUniqueRenters != null ||
        seats != null ||
        minOwnerRating != null ||
        (query != null && query!.trim().isNotEmpty);
  }

  /// Seçili aktif filtrelerin toplam adedini döner.
  int get activeFilterCount {
    int count = 0;
    if (minAge != null || maxAge != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minKm != null || maxKm != null) count++;
    if (centerCity != null) count++;
    if (brands != null && brands!.isNotEmpty) count++;
    if (models != null && models!.isNotEmpty) count++;
    if (fuelTypes != null && fuelTypes!.isNotEmpty) count++;
    if (bodyTypes != null && bodyTypes!.isNotEmpty) count++;
    if (transmissions != null && transmissions!.isNotEmpty) count++;
    if (minCompletedRentals != null) count++;
    if (maxConsumption != null) count++;
    if (colors != null && colors!.isNotEmpty) count++;
    if (minEngineCc != null || maxEngineCc != null) count++;
    if (minWidthMm != null || maxWidthMm != null) count++;
    if (minWeightKg != null || maxWeightKg != null) count++;
    if (minUniqueRenters != null) count++;
    if (seats != null) count++;
    if (minOwnerRating != null) count++;
    return count;
  }

  /// Mevcut filtre nesnesini belirli alanlarını güncelleyerek kopyalar.
  VehicleFilter copyWith({
    double? minAge,
    double? maxAge,
    double? minPrice,
    double? maxPrice,
    double? minKm,
    double? maxKm,
    String? centerCity,
    double? centerLat,
    double? centerLng,
    double? radiusKm,
    List<String>? brands,
    List<String>? models,
    List<String>? fuelTypes,
    List<String>? bodyTypes,
    List<String>? transmissions,
    int? minCompletedRentals,
    double? maxConsumption,
    List<String>? colors,
    int? minEngineCc,
    int? maxEngineCc,
    int? minWidthMm,
    int? maxWidthMm,
    int? minWeightKg,
    int? maxWeightKg,
    int? minUniqueRenters,
    int? seats,
    double? minOwnerRating,
    String? sortBy,
    String? query,
    bool clearCenterCity = false,
  }) {
    return VehicleFilter(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minKm: minKm ?? this.minKm,
      maxKm: maxKm ?? this.maxKm,
      centerCity: clearCenterCity ? null : (centerCity ?? this.centerCity),
      centerLat: clearCenterCity ? null : (centerLat ?? this.centerLat),
      centerLng: clearCenterCity ? null : (centerLng ?? this.centerLng),
      radiusKm: clearCenterCity ? null : (radiusKm ?? this.radiusKm),
      brands: brands ?? this.brands,
      models: models ?? this.models,
      fuelTypes: fuelTypes ?? this.fuelTypes,
      bodyTypes: bodyTypes ?? this.bodyTypes,
      transmissions: transmissions ?? this.transmissions,
      minCompletedRentals: minCompletedRentals ?? this.minCompletedRentals,
      maxConsumption: maxConsumption ?? this.maxConsumption,
      colors: colors ?? this.colors,
      minEngineCc: minEngineCc ?? this.minEngineCc,
      maxEngineCc: maxEngineCc ?? this.maxEngineCc,
      minWidthMm: minWidthMm ?? this.minWidthMm,
      maxWidthMm: maxWidthMm ?? this.maxWidthMm,
      minWeightKg: minWeightKg ?? this.minWeightKg,
      maxWeightKg: maxWeightKg ?? this.maxWeightKg,
      minUniqueRenters: minUniqueRenters ?? this.minUniqueRenters,
      seats: seats ?? this.seats,
      minOwnerRating: minOwnerRating ?? this.minOwnerRating,
      sortBy: sortBy ?? this.sortBy,
      query: query ?? this.query,
    );
  }

  /// Verilen araç listesini mevcut filtrelere göre süzüp sıralar.
  List<Vehicle> apply(List<Vehicle> list) {
    var result = list.where((v) {
      // Query filter (search in brand, model, city, color)
      if (query != null && query!.trim().isNotEmpty) {
        final q = query!.trim().toLowerCase();
        final match = v.brand.toLowerCase().contains(q) ||
            v.model.toLowerCase().contains(q) ||
            v.city.toLowerCase().contains(q) ||
            v.color.toLowerCase().contains(q);
        if (!match) return false;
      }

      // Age filter
      if (minAge != null && v.age < minAge!) return false;
      if (maxAge != null && v.age > maxAge!) return false;

      // Price filter
      if (minPrice != null && v.dailyPrice < minPrice!) return false;
      if (maxPrice != null && v.dailyPrice > maxPrice!) return false;

      // Km filter
      if (minKm != null && v.km < minKm!) return false;
      if (maxKm != null && v.km > maxKm!) return false;

      // Brand filter
      if (brands != null && brands!.isNotEmpty && !brands!.contains(v.brand)) {
        return false;
      }

      // Model filter
      if (models != null && models!.isNotEmpty && !models!.contains(v.model)) {
        return false;
      }

      // Fuel type filter
      if (fuelTypes != null &&
          fuelTypes!.isNotEmpty &&
          !fuelTypes!.contains(v.fuelType)) {
        return false;
      }

      // Body type filter
      if (bodyTypes != null &&
          bodyTypes!.isNotEmpty &&
          !bodyTypes!.contains(v.bodyType)) {
        return false;
      }

      // Transmission filter
      if (transmissions != null &&
          transmissions!.isNotEmpty &&
          !transmissions!.contains(v.transmission)) {
        return false;
      }

      // Min completed rentals
      if (minCompletedRentals != null &&
          v.completedRentalCount < minCompletedRentals!) {
        return false;
      }

      // Fuel consumption (if null, e.g. electric, allow or match)
      if (maxConsumption != null && v.fuelConsumption != null) {
        if (v.fuelConsumption! > maxConsumption!) return false;
      }

      // Color filter
      if (colors != null && colors!.isNotEmpty && !colors!.contains(v.color)) {
        return false;
      }

      // Engine CC
      if (minEngineCc != null && v.engineCc != null && v.engineCc! < minEngineCc!) {
        return false;
      }
      if (maxEngineCc != null && v.engineCc != null && v.engineCc! > maxEngineCc!) {
        return false;
      }

      // Width & Weight
      if (minWidthMm != null && v.widthMm < minWidthMm!) return false;
      if (maxWidthMm != null && v.widthMm > maxWidthMm!) return false;
      if (minWeightKg != null && v.weightKg < minWeightKg!) return false;
      if (maxWeightKg != null && v.weightKg > maxWeightKg!) return false;

      // Unique renters
      if (minUniqueRenters != null && v.uniqueRenterCount < minUniqueRenters!) {
        return false;
      }

      // Seats
      if (seats != null && v.seats != seats!) return false;

      // Rating
      if (minOwnerRating != null && v.ratingAvg < minOwnerRating!) return false;

      // Distance / Haversine
      if (centerLat != null && centerLng != null && radiusKm != null) {
        final dist = Haversine.calculateDistanceKm(
          lat1: centerLat!,
          lng1: centerLng!,
          lat2: v.lat,
          lng2: v.lng,
        );
        if (dist > radiusKm!) return false;
      }

      return true;
    }).toList();

    // Sorting
    switch (sortBy) {
      case 'price_asc':
        result.sort((a, b) => a.dailyPrice.compareTo(b.dailyPrice));
        break;
      case 'price_desc':
        result.sort((a, b) => b.dailyPrice.compareTo(a.dailyPrice));
        break;
      case 'newest':
        result.sort((a, b) => b.modelYear.compareTo(a.modelYear));
        break;
      case 'rating':
        result.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
        break;
      case 'popularity':
        result.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
        break;
      case 'recommended':
      default:
        result.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
        break;
    }

    return result;
  }
}
