/// Dosya: lib/core/constants/app_strings.dart
/// Görev / İşlev: Uygulama genelindeki tüm sabit metinleri (UI etiketleri,
/// buton yazıları, hata ve geri bildirim mesajları, sekme isimleri) tek bir
/// merkezden yöneterek kod tekrarını önler ve yerelleştirmeyi (i18n) kolaylaştırır.

class AppStrings {
  // Sınıfın dışarıdan örneklenmesini engellemek için private constructor
  AppStrings._();

  static const String appName = 'OtoKirala';
  static const String appTagline = 'Güvenilir ve Kolay Araç Kiralama';

  // Auth
  static const String login = 'Giriş Yap';
  static const String register = 'Kayıt Ol';
  static const String logout = 'Çıkış Yap';
  static const String email = 'E-posta';
  static const String password = 'Şifre';
  static const String passwordConfirm = 'Şifre Tekrar';
  static const String fullName = 'Ad Soyad';
  static const String phone = 'Telefon Numarası';
  static const String birthDate = 'Doğum Tarihi';
  static const String profession = 'Meslek';
  static const String maritalStatus = 'Medeni Hal';
  static const String gender = 'Cinsiyet';
  static const String single = 'Bekar';
  static const String married = 'Evli';
  static const String male = 'Erkek';
  static const String female = 'Kadın';
  static const String selectRole = 'Rol Seçiniz';
  static const String roleRenter = 'Kiracı';
  static const String roleOwner = 'Kiraya Veren';
  static const String roleBoth = 'Her İkisi';
  static const String switchRole = 'Rol Değiştir';
  static const String switchToOwner = 'Kiraya Veren Moduna Geç';
  static const String switchToRenter = 'Kiracı Moduna Geç';

  // Navigation Tabs - Renter
  static const String navExplore = 'Keşfet';
  static const String navPopular = 'Popüler';
  static const String navMyRentals = 'Kiralamalarım';
  static const String navChats = 'Sohbet';
  static const String navProfile = 'Profil';

  // Navigation Tabs - Owner
  static const String navMyListings = 'İlanlarım';
  static const String navIncomingOffers = 'Teklifler';
  static const String navRentalHistory = 'Geçmiş İşlemler';

  // Search & Filter
  static const String searchVehicles = 'Araç veya marka ara...';
  static const String filters = 'Filtreler';
  static const String clearFilters = 'Filtreleri Temizle';
  static const String showResults = 'Sonuçları Göster';
  static const String noResults = 'Aramanıza uygun araç bulunamadı';
  static const String tryBroadeningFilters = 'Fiyat aralığını veya km limitini genişleterek tekrar deneyebilirsiniz.';
  static const String sortBy = 'Sıralama';
  static const String sortRecommended = 'Önerilen';
  static const String sortPriceAsc = 'Fiyat: Düşükten Yükseğe';
  static const String sortPriceDesc = 'Fiyat: Yüksekten Düşüğe';
  static const String sortNewest = 'En Yeni Model';
  static const String sortRating = 'En Yüksek Puan';
  static const String sortPopularity = 'En Popüler';

  // Vehicle Details
  static const String dailyPrice = 'Günlük Fiyat';
  static const String deposit = 'Depozito';
  static const String kmLimit = 'Günlük KM Limiti';
  static const String fuelType = 'Yakıt Türü';
  static const String transmission = 'Vites';
  static const String bodyType = 'Kasa Tipi';
  static const String seats = 'Koltuk Sayısı';
  static const String engineCc = 'Motor Hacmi';
  static const String fuelConsumption = 'Yakıt Tüketimi';
  static const String vehicleAge = 'Araç Yaşı';
  static const String technicalSpecs = 'Teknik Özellikler';
  static const String ownerInfo = 'Araç Sahibi';
  static const String reviews = 'Değerlendirmeler';
  static const String makeOffer = 'Teklif Gönder';
  static const String cannotRentOwnVehicle = 'Kendi ilanınıza kiralama teklifi veremezsiniz.';

  // Listing Management
  static const String addNewListing = 'Yeni İlan Ver';
  static const String stepVehicleInfo = 'Araç Bilgisi';
  static const String stepTechnical = 'Teknik Özellikler';
  static const String stepPriceConditions = 'Fiyat & Koşullar';
  static const String stepLocation = 'Konum';
  static const String stepPhotos = 'Fotoğraflar';
  static const String stepPreview = 'Önizleme & Yayın';

  // Actions
  static const String cancel = 'Vazgeç';
  static const String approve = 'Onayla';
  static const String reject = 'Reddet';
  static const String counterOffer = 'Karşı Teklif';
  static const String rateAndReview = 'Değerlendir';
  static const String deliveryConfirm = 'Teslim Alındı / Edildi';
  static const String returnConfirm = 'İade Edildi / Alındı';
  static const String pauseListing = 'İlanı Duraklat';
  static const String activateListing = 'İlanı Yayına Al';
  static const String deleteListing = 'İlanı Sil';

  // Feedback & Dialogs
  static const String ratingTitle = 'Kiralama Değerlendirmesi';
  static const String ratingCommentHint = 'Deneyiminizi anlatın (isteğe bağlı, maks 500 karakter)...';
  static const String ratingSubmit = 'Değerlendirmeyi Kaydet';
  static const String success = 'Başarılı';
  static const String error = 'Hata';
}
