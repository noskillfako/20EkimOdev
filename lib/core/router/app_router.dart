import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/chat/presentation/chat_list_screen.dart';
import '../../features/chat/presentation/chat_room_screen.dart';
import '../../features/gallery/component_gallery_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/rentals/presentation/incoming_offers_screen.dart';
import '../../features/rentals/presentation/my_rentals_screen.dart';
import '../../features/rentals/presentation/owner_rentals_screen.dart';
import '../../features/search/presentation/explore_screen.dart';
import '../../features/vehicles/presentation/add_vehicle_screen.dart';
import '../../features/vehicles/presentation/my_listings_screen.dart';
import '../../features/vehicles/presentation/popular_screen.dart';
import '../../features/vehicles/presentation/vehicle_detail_screen.dart';
import '../constants/app_routes.dart';
import '../widgets/main_shell.dart';

// GoRouter tabanlı yönlendirme yöneticisi (Routing Provider)
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash, // İlk açılışta gösterilecek rota
    debugLogDiagnostics: false, // Konsol yönlendirme loglarını sessize al
    routes: [
      // 1. Açılış Ekranı (Splash)
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Giriş Ekranı (Login)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // 3. Kayıt Ol Ekranı (Register)
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // 4. Araç Detay Ekranı (ID parametresi alır)
      GoRoute(
        path: AppRoutes.vehicleDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? ''; // URL parametresinden araç ID'sini alıyoruz
          return VehicleDetailScreen(vehicleId: id);
        },
      ),

      // 5. Sohbet Odası Ekranı (Sohbet ID parametresi alır)
      GoRoute(
        path: AppRoutes.chatRoom,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? ''; // URL parametresinden sohbet ID'sini alıyoruz
          return ChatRoomScreen(chatId: id);
        },
      ),

      // 6. Yeni Araç Ekleme Ekranı (Çok adımlı form)
      GoRoute(
        path: AppRoutes.addVehicle,
        builder: (context, state) => const AddVehicleScreen(),
      ),

      // 7. Profil Düzenleme Ekranı
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),

      // 8. Tasarım Sistemi Bileşen Galerisi (Component Gallery)
      GoRoute(
        path: AppRoutes.gallery,
        builder: (context, state) => const ComponentGalleryScreen(),
      ),

      // 9. Ana Kabuk: Alt Navigasyon Çubuğu (BottomNavigationBar) ile IndexedStack tabanlı sekmeli yapı
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Alt bar ve sayfa yapısını saran ana iskelet widget
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Sekme 0: Keşfet (Kiracı) veya İlanlarım (Araç Sahibi)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                builder: (context, state) => const _DynamicHomeBranch(),
              ),
              GoRoute(
                path: AppRoutes.myListings,
                builder: (context, state) => const _DynamicHomeBranch(),
              ),
            ],
          ),

          // Sekme 1: Popüler Araçlar (Kiracı) veya Gelen Teklifler (Araç Sahibi)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.popular,
                builder: (context, state) => const _DynamicBranchOne(),
              ),
              GoRoute(
                path: AppRoutes.incomingOffers,
                builder: (context, state) => const _DynamicBranchOne(),
              ),
            ],
          ),

          // Sekme 2: Kiralama Geçmişim (Kiracı) veya Araç Kiralama Talepleri (Araç Sahibi)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.myRentals,
                builder: (context, state) => const _DynamicBranchTwo(),
              ),
              GoRoute(
                path: AppRoutes.rentalHistory,
                builder: (context, state) => const _DynamicBranchTwo(),
              ),
            ],
          ),

          // Sekme 3: Mesajlar / Sohbet Listesi
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chatList,
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),

          // Sekme 4: Profil ve Hesap Ayarları
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Aktif role göre 1. Sekmeyi (Ana Sayfa) dinamik belirleyen widget
class _DynamicHomeBranch extends ConsumerWidget {
  const _DynamicHomeBranch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Giriş yapmış kullanıcının aktif rolünü kontrol ediyoruz
    final user = ref.watch(authControllerProvider).value;
    if (user?.activeRole == 'owner') {
      return const MyListingsScreen(); // Araç sahibi ise kendi ilanlarını göster
    }
    return const ExploreScreen(); // Kiracı ise araç keşfet / arama sayfasını göster
  }
}

// Aktif role göre 2. Sekmeyi dinamik belirleyen widget
class _DynamicBranchOne extends ConsumerWidget {
  const _DynamicBranchOne();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Giriş yapmış kullanıcının aktif rolünü kontrol ediyoruz
    final user = ref.watch(authControllerProvider).value;
    if (user?.activeRole == 'owner') {
      return const IncomingOffersScreen(); // Araç sahibi ise bekleyen teklifleri göster
    }
    return const PopularScreen(); // Kiracı ise popüler ve öne çıkan araçları göster
  }
}

// Aktif role göre 3. Sekmeyi dinamik belirleyen widget
class _DynamicBranchTwo extends ConsumerWidget {
  const _DynamicBranchTwo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Giriş yapmış kullanıcının aktif rolünü kontrol ediyoruz
    final user = ref.watch(authControllerProvider).value;
    if (user?.activeRole == 'owner') {
      return const OwnerRentalsScreen(); // Araç sahibi ise kiralanan araçlarının durumunu göster
    }
    return const MyRentalsScreen(); // Kiracı ise yaptığı kiralamaları göster
  }
}
