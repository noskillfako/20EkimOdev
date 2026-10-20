import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

// Kullanıcı oturumu, kimlik doğrulama ve rol geçiş durumunu yöneten Riverpod State Notifier Sağlayıcısı
final authControllerProvider = NotifierProvider<AuthController, AsyncValue<AppUser?>>(() {
  return AuthController();
});

// Kimlik doğrulama ve aktif kullanıcı durum denetleyicisi
class AuthController extends Notifier<AsyncValue<AppUser?>> {
  // SharedPreferences'ta kayıtlı kullanıcı kimliği için anahtar kelime
  static const _savedUserIdKey = 'saved_user_id';

  @override
  AsyncValue<AppUser?> build() {
    // Uygulama açılışında kayıtlı oturumu geri yükle
    _restoreSession();
    return const AsyncValue.loading();
  }

  // Cihaz hafızasındaki (SharedPreferences) kullanıcı oturumunu yükler
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_savedUserIdKey);
      if (savedId != null) {
        // Kayıtlı kullanıcı ID'si varsa repository üzerinden getir
        final repo = ref.read(authRepositoryProvider);
        final user = await repo.getCurrentUser(savedId);
        if (user != null) {
          state = AsyncValue.data(user);
          return;
        }
      }
      // Oturum yoksa varsayılan demo kullanıcıyı ('usr_001' - Ali Yılmaz) yükle
      final repo = ref.read(authRepositoryProvider);
      final defaultUser = await repo.getCurrentUser('usr_001'); // Ali Yılmaz (Kiracı)
      state = AsyncValue.data(defaultUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // E-posta ve şifre ile giriş yapma işlemi
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email, password); // Kimlik doğrulama
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedUserIdKey, user.id); // Oturumu cihaza kaydet
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Yeni kullanıcı kayıt işlemi
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String birthDate,
    required String profession,
    required String maritalStatus,
    required String gender,
    required List<String> roles,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        birthDate: birthDate,
        profession: profession,
        maritalStatus: maritalStatus,
        gender: gender,
        roles: roles,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedUserIdKey, user.id); // Oturumu cihaza kaydet
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Kiracı ve Araç Sahibi rolleri arasında anında geçiş yapma metodu
  Future<void> switchRole(String newRole) async {
    final current = state.value;
    if (current == null) return;

    // Eğer kullanıcı daha önce bu role sahip değilse, ikinci profili dinamik olarak ekle
    if (!current.roles.contains(newRole)) {
      final updatedRoles = [...current.roles, newRole];
      final updatedUser = current.copyWith(
        roles: updatedRoles,
        activeRole: newRole,
        // Araç sahibi profili yoksa sıfırdan oluştur
        ownerProfile: newRole == 'owner' && current.ownerProfile == null
            ? const OwnerProfile(listingCount: 0, rentedOutCount: 0, ratingAvg: 5.0, ratingCount: 0)
            : current.ownerProfile,
        // Kiracı profili yoksa sıfırdan oluştur
        renterProfile: newRole == 'renter' && current.renterProfile == null
            ? const RenterProfile(rentedCount: 0, ratingAvg: 5.0, ratingCount: 0)
            : current.renterProfile,
      );
      state = AsyncValue.data(updatedUser);
      return;
    }

    // Var olan rol durumunu güncelle
    state = AsyncValue.data(current.copyWith(activeRole: newRole));
  }

  // Profil düzenleme ekranından gelen güncel kullanıcı verisini state'e uygula
  void updateUserData(AppUser updatedUser) {
    state = AsyncValue.data(updatedUser);
  }

  // Çıkış yapma (Logout) işlemi
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedUserIdKey); // Cihaz hafızasındaki oturumu temizle
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncValue.data(null); // Durumu sıfırla
  }
}
