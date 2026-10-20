/// Dosya: lib/core/data/mock_store.dart
/// Görev / İşlev: Uygulamanın bellek içi (In-Memory) sahte veri deposudur (Mock Data Store).
/// assets/mock/ klasöründeki JSON dosyalarından kullanıcı, araç, kiralama, değerlendirme ve
/// sohbet verilerini belleğe yükler; istatistikleri (puan, kiralama sayısı vb.) otomatik
/// hesaplar ve favori araçları SharedPreferences ile kalıcı kılar.

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/chat/domain/chat.dart';
import '../../features/rentals/domain/rental.dart';
import '../../features/reviews/domain/review.dart';
import '../../features/vehicles/domain/vehicle.dart';

// MockStore sağlayıcısı (main.dart içinde ProviderScope override ile ezilir)
final mockStoreProvider = Provider<MockStore>((ref) {
  throw UnimplementedError('MockStore must be initialized before use');
});

// Uygulamanın tüm verilerini RAM üzerinde tutan ana In-Memory Veri Deposu
class MockStore {
  final List<AppUser> users; // Kayıtlı tüm kullanıcılar
  final List<Vehicle> vehicles; // Sistemdeki tüm araçlar
  final List<Rental> rentals; // Kiralama ve rezervasyon kayıtları
  final List<Review> reviews; // Karşılıklı değerlendirme ve puanlar
  final List<Chat> chats; // Kullanıcılar arası mesajlaşmalar
  final Map<String, dynamic> catalog; // Şehir, marka, model, donanım kataloğu
  final Set<String> favoriteVehicleIds; // Kullanıcının favoriye aldığı araç ID'leri

  MockStore({
    required this.users,
    required this.vehicles,
    required this.rentals,
    required this.reviews,
    required this.chats,
    required this.catalog,
    Set<String>? favoriteVehicleIds,
  }) : favoriteVehicleIds = favoriteVehicleIds ?? {};

  // assets/mock/ altındaki JSON dosyalarından verileri okuyup MockStore oluşturan asenkron metot
  static Future<MockStore> loadFromAssets() async {
    // 1. JSON dosyalarını assets klasöründen asenkron oku
    final usersJsonStr = await rootBundle.loadString('assets/mock/users.json');
    final vehiclesJsonStr = await rootBundle.loadString('assets/mock/vehicles.json');
    final rentalsJsonStr = await rootBundle.loadString('assets/mock/rentals.json');
    final reviewsJsonStr = await rootBundle.loadString('assets/mock/reviews.json');
    final chatsJsonStr = await rootBundle.loadString('assets/mock/chats.json');
    final catalogJsonStr = await rootBundle.loadString('assets/mock/catalog.json');

    // 2. JSON metinlerini Dart modellerine dönüştür
    final usersList = (jsonDecode(usersJsonStr) as List<dynamic>)
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();

    final vehiclesList = (jsonDecode(vehiclesJsonStr) as List<dynamic>)
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();

    final rentalsList = (jsonDecode(rentalsJsonStr) as List<dynamic>)
        .map((e) => Rental.fromJson(e as Map<String, dynamic>))
        .toList();

    final reviewsList = (jsonDecode(reviewsJsonStr) as List<dynamic>)
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();

    final chatsList = (jsonDecode(chatsJsonStr) as List<dynamic>)
        .map((e) => Chat.fromJson(e as Map<String, dynamic>))
        .toList();

    final catalogMap = jsonDecode(catalogJsonStr) as Map<String, dynamic>;

    // 3. SharedPreferences üzerinden yerel favori araç listesini çek
    final Set<String> favorites = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('user_favorites') ?? [];
      favorites.addAll(favList);
    } catch (_) {
      // Hata durumunda boş favori listesiyle devam et
    }

    // 4. Bellek içi depoyu başlat
    final store = MockStore(
      users: usersList,
      vehicles: vehiclesList,
      rentals: rentalsList,
      reviews: reviewsList,
      chats: chatsList,
      catalog: catalogMap,
      favoriteVehicleIds: favorites,
    );

    // 5. Matematiksel tutarlılık için tüm istatistikleri ve puan ortalamalarını hesapla
    store.recomputeAll();

    return store;
  }

  // Tüm araçların ve kullanıcıların istatistiklerini baştan hesaplar
  void recomputeAll() {
    for (final v in vehicles) {
      recomputeVehicleStats(v.id);
    }
    for (final u in users) {
      recomputeUserStats(u.id);
    }
  }

  // Belirli bir aracın tamamlanan kiralama, farklı kiracı ve puan ortalamasını hesaplar
  void recomputeVehicleStats(String vehicleId) {
    final vIndex = vehicles.indexWhere((v) => v.id == vehicleId);
    if (vIndex == -1) return;

    final v = vehicles[vIndex];
    // Tamamlanan kiralamaları filtrele
    final completed = rentals.where((r) => r.vehicleId == vehicleId && r.isCompleted).toList();
    // Kaç farklı benzersiz kiracının kiraladığını bul
    final uniqueRenters = completed.map((r) => r.renterId).toSet().length;

    // Araca verilen yıldızları toplayıp ortalama al
    final vReviews = reviews.where((r) => r.vehicleId == vehicleId && r.vehicleStars != null).toList();
    double avg = 5.0;
    int count = vReviews.length;
    if (count > 0) {
      final sum = vReviews.fold<int>(0, (prev, el) => prev + (el.vehicleStars ?? 5));
      avg = double.parse((sum / count).toStringAsFixed(1));
    } else {
      avg = v.ratingAvg > 0 ? v.ratingAvg : 4.8;
      count = v.ratingCount > 0 ? v.ratingCount : completed.length;
    }

    // Popülerlik skoru formülü: (Tamamlanan * 3) + (Ortalama Puan * 10) + (Farklı Kiracı * 2)
    final popularity = (completed.length * 3.0) + (avg * 10.0) + (uniqueRenters * 2.0);

    // Araç nesnesini yeni hesaplanan değerlerle güncelle
    vehicles[vIndex] = v.copyWith(
      completedRentalCount: completed.length,
      uniqueRenterCount: uniqueRenters,
      ratingAvg: avg,
      ratingCount: count,
      popularityScore: double.parse(popularity.toStringAsFixed(1)),
    );
  }

  // Kullanıcının Kiracı ve Araç Sahibi istatistiklerini hesaplar
  void recomputeUserStats(String userId) {
    final uIndex = users.indexWhere((u) => u.id == userId);
    if (uIndex == -1) return;

    final u = users[uIndex];

    // 1. Kiracı Rolü İstatistikleri
    if (u.isRenter) {
      final rented = rentals.where((r) => r.renterId == userId && r.isCompleted).toList();
      final rReviews = reviews.where((r) => r.targetId == userId && r.targetRole == 'renter').toList();
      double rAvg = 5.0;
      if (rReviews.isNotEmpty) {
        final sum = rReviews.fold<int>(0, (prev, el) => prev + el.stars);
        rAvg = double.parse((sum / rReviews.length).toStringAsFixed(1));
      }
      final newRenterProfile = (u.renterProfile ?? const RenterProfile(rentedCount: 0, ratingAvg: 5.0, ratingCount: 0)).copyWith(
        rentedCount: rented.length,
        ratingAvg: rAvg,
        ratingCount: rReviews.length,
      );
      users[uIndex] = users[uIndex].copyWith(renterProfile: newRenterProfile);
    }

    // 2. Araç Sahibi Rolü İstatistikleri
    if (u.isOwner) {
      final listings = vehicles.where((v) => v.ownerId == userId).toList();
      final rentedOut = rentals.where((r) => r.ownerId == userId && r.isCompleted).toList();
      final oReviews = reviews.where((r) => r.targetId == userId && r.targetRole == 'owner').toList();
      double oAvg = 5.0;
      if (oReviews.isNotEmpty) {
        final sum = oReviews.fold<int>(0, (prev, el) => prev + el.stars);
        oAvg = double.parse((sum / oReviews.length).toStringAsFixed(1));
      }
      final newOwnerProfile = (u.ownerProfile ?? const OwnerProfile(listingCount: 0, rentedOutCount: 0, ratingAvg: 5.0, ratingCount: 0)).copyWith(
        listingCount: listings.length,
        rentedOutCount: rentedOut.length,
        ratingAvg: oAvg,
        ratingCount: oReviews.length,
      );
      users[uIndex] = users[uIndex].copyWith(ownerProfile: newOwnerProfile);
    }
  }

  // Araç favori durumunu tersine çevir (aç/kapa) ve SharedPreferences'a kaydet
  void toggleFavorite(String vehicleId) async {
    if (favoriteVehicleIds.contains(vehicleId)) {
      favoriteVehicleIds.remove(vehicleId); // Zaten favorideyse kaldır
    } else {
      favoriteVehicleIds.add(vehicleId); // Favoride değilse ekle
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_favorites', favoriteVehicleIds.toList());
    } catch (_) {
      // SharedPreferences hatası yakalama
    }
  }
}
