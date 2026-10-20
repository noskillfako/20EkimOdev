/// Dosya: lib/core/constants/app_routes.dart
/// Görev / İşlev: Uygulama içindeki tüm sayfa ve rotaların (routes) URL yollarını,
/// sekme adreslerini ve dinamik parametreli rotalara geçiş için yardımcı metotları
/// tek bir merkezi sınıfta toplar.

class AppRoutes {
  // Sınıfın dışarıdan örneklenmesini (instance oluşturulmasını) engellemek için private constructor
  AppRoutes._();

  // Temel Kimlik Doğrulama Rotaları
  static const String splash = '/'; // Açılış animasyon ekranı rotası
  static const String onboarding = '/onboarding'; // Tanıtım / karşılama rotası
  static const String login = '/login'; // Kullanıcı giriş ekranı rotası
  static const String register = '/register'; // Yeni kullanıcı kayıt ekranı rotası

  // Kiracı (Renter) Sekme Rotaları
  static const String explore = '/explore'; // Araç arama ve keşfet sekmesi rotası
  static const String popular = '/popular'; // En popüler araçlar sekmesi rotası
  static const String myRentals = '/my-rentals'; // Kiracının kiralama geçmişi sekmesi rotası

  // Araç Sahibi (Owner) Sekme Rotaları
  static const String myListings = '/my-listings'; // Araç sahibinin ilanları sekmesi rotası
  static const String incomingOffers = '/incoming-offers'; // Gelen kiralama teklifleri sekmesi rotası
  static const String rentalHistory = '/rental-history'; // Tamamlanan kiralama işlemleri sekmesi rotası

  // Ortak Sekme Rotaları
  static const String chatList = '/chats'; // Mesajlaşmalar / sohbet listesi sekmesi rotası
  static const String profile = '/profile'; // Kullanıcı profili ve ayarlar sekmesi rotası

  // Yığına Eklenen Bağımsız Sayfa Rotaları (Pushed Screens)
  static const String vehicleDetail = '/vehicle/:id'; // Araç detay sayfası rotası (:id parametreli)
  static const String chatRoom = '/chat/:id'; // İkili sohbet odası rotası (:id parametreli)
  static const String addVehicle = '/add-vehicle'; // Yeni araç ilanı ekleme sihirbazı rotası
  static const String editProfile = '/edit-profile'; // Profil bilgileri güncelleme ekranı rotası
  static const String settings = '/settings'; // Uygulama ayarları rotası
  static const String gallery = '/gallery'; // Tasarım sistemi bileşen galerisi rotası

  // Rota Yardımcı Fonksiyonları (Helpers)

  /// Verilen araç ID'sine göre dinamik araç detay URL yolunu oluşturur.
  /// Örn: id = 'veh_001' ise '/vehicle/veh_001' sonucunu döner.
  static String vehicleDetailPath(String id) => '/vehicle/$id';

  /// Verilen sohbet ID'sine göre dinamik sohbet odası URL yolunu oluşturur.
  /// Örn: id = 'chat_001' ise '/chat/chat_001' sonucunu döner.
  static String chatRoomPath(String id) => '/chat/$id';
}

