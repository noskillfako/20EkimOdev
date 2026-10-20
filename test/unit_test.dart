import 'package:flutter_test/flutter_test.dart';
import 'package:arackiralama/core/utils/haversine.dart';
import 'package:arackiralama/core/validators/validators.dart';
import 'package:arackiralama/features/vehicles/domain/vehicle.dart';
import 'package:arackiralama/features/search/domain/vehicle_filter.dart';

void main() {
  group('Validators Unit Tests', () {
    test('Email validation returns null for valid emails and error for invalid', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail('user.name+tag@domain.co'), isNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('@nodomain.com'), isNotNull);
    });

    test('Password validation enforces min 8 chars and alphanumeric', () {
      expect(Validators.validatePassword('password123'), isNull);
      expect(Validators.validatePassword('short1'), isNotNull);
      expect(Validators.validatePassword('allletterspassword'), isNotNull);
      expect(Validators.validatePassword('12345678'), isNotNull);
    });

    test('Phone validation checks 10 digits', () {
      expect(Validators.validatePhone('5321002030'), isNull);
      expect(Validators.validatePhone('+90 532 100 20 30'), isNull);
      expect(Validators.validatePhone('12345'), isNotNull);
    });

    test('Birth date validator requires age >= 18', () {
      final adult = DateTime(1995, 5, 20);
      final minor = DateTime.now().subtract(const Duration(days: 365 * 16));
      expect(Validators.validateBirthDate(adult), isNull);
      expect(Validators.validateBirthDate(minor), isNotNull);
    });

    test('Price and KM validation boundaries', () {
      expect(Validators.validatePrice('1500'), isNull);
      expect(Validators.validatePrice('-50'), isNotNull);
      expect(Validators.validatePrice('0'), isNotNull);

      expect(Validators.validateKm('45000'), isNull);
      expect(Validators.validateKm('-10'), isNotNull);
      expect(Validators.validateKm('2000000'), isNotNull);
    });
  });

  group('Haversine Distance Tests', () {
    test('Calculates distance between Istanbul and Ankara reasonably (~350 km)', () {
      final distance = Haversine.calculateDistanceKm(
        lat1: 41.0082,
        lng1: 28.9784,
        lat2: 39.9334,
        lng2: 32.8597,
      );
      expect(distance, greaterThan(340));
      expect(distance, lessThan(360));
    });

    test('Same point returns zero distance', () {
      final distance = Haversine.calculateDistanceKm(
        lat1: 41.0082,
        lng1: 28.9784,
        lat2: 41.0082,
        lng2: 28.9784,
      );
      expect(distance, closeTo(0.0, 0.01));
    });
  });

  group('VehicleFilter Filtering Tests', () {
    final sampleVehicles = [
      const Vehicle(
        id: 'v1',
        ownerId: 'u1',
        brand: 'Renault',
        model: 'Clio',
        modelYear: 2022,
        km: 30000,
        fuelType: 'benzin',
        bodyType: 'hatchback',
        transmission: 'otomatik',
        color: 'Kırmızı',
        widthMm: 1798,
        weightKg: 1200,
        seats: 5,
        dailyPrice: 1200,
        deposit: 4000,
        dailyKmLimit: 250,
        minRentalDays: 1,
        maxRentalDays: 30,
        city: 'İstanbul',
        lat: 41.0082,
        lng: 28.9784,
        photos: [],
        status: 'active',
        description: 'Test',
        ratingAvg: 4.8,
        popularityScore: 50.0,
      ),
      const Vehicle(
        id: 'v2',
        ownerId: 'u2',
        brand: 'Tesla',
        model: 'Model Y',
        modelYear: 2023,
        km: 15000,
        fuelType: 'elektrik',
        bodyType: 'suv',
        transmission: 'otomatik',
        color: 'Beyaz',
        widthMm: 1921,
        weightKg: 1979,
        seats: 5,
        dailyPrice: 3500,
        deposit: 12000,
        dailyKmLimit: 400,
        minRentalDays: 1,
        maxRentalDays: 30,
        city: 'Ankara',
        lat: 39.9334,
        lng: 32.8597,
        photos: [],
        status: 'active',
        description: 'Test',
        ratingAvg: 5.0,
        popularityScore: 90.0,
      ),
    ];

    test('Filter by Brand', () {
      const filter = VehicleFilter(brands: ['Renault']);
      final results = filter.apply(sampleVehicles);
      expect(results.length, 1);
      expect(results.first.brand, 'Renault');
    });

    test('Filter by Fuel Type', () {
      const filter = VehicleFilter(fuelTypes: ['elektrik']);
      final results = filter.apply(sampleVehicles);
      expect(results.length, 1);
      expect(results.first.fuelType, 'elektrik');
    });

    test('Filter by Price Range', () {
      const filter = VehicleFilter(minPrice: 2000, maxPrice: 4000);
      final results = filter.apply(sampleVehicles);
      expect(results.length, 1);
      expect(results.first.id, 'v2');
    });

    test('Sort by Price Ascending', () {
      const filter = VehicleFilter(sortBy: 'price_asc');
      final results = filter.apply(sampleVehicles);
      expect(results.first.dailyPrice, 1200);
      expect(results.last.dailyPrice, 3500);
    });
  });
}
