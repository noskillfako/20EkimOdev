/// Dosya: lib/core/widgets/main_shell.dart
/// Görev / İşlev: Uygulamanın ana kabuk widget'ıdır (Main Shell).
/// Giriş yapmış kullanıcının aktif rolüne (Kiracı / Araç Sahibi) göre alt navigasyon
/// çubuğunun (NavigationBar) sekmelerini ve okunmamış mesaj sayacı rozetlerini (Badge) dinamik oluşturur.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/chat/presentation/chat_providers.dart';
import '../constants/app_strings.dart';

// Alt Navigasyon Çubuğunu (NavigationBar) ve sekmeleri barındıran ana uygulama kabuğu
class MainShell extends ConsumerWidget {
  // GoRouter'ın durum korumalı navigasyon kabuğu nesnesi
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Aktif kullanıcının durumunu dinliyoruz
    final user = ref.watch(authControllerProvider).value;
    // Kullanıcının şu anda "Araç Sahibi" modunda olup olmadığını kontrol ediyoruz
    final isOwnerMode = user?.activeRole == 'owner';
    // Okunmamış sohbet mesaj sayısını dinliyoruz (Sohbet sekmesi rozeti için)
    final unreadCount = ref.watch(unreadMessageCountProvider);

    return Scaffold(
      body: navigationShell, // Aktif sekmenin sayfa gövdesi
      // Material 3 Alt Navigasyon Çubuğu
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex, // Seçili sekme indeksi
        onDestinationSelected: (index) {
          // Tıklanan sekmeye geçiş yap, aynı sekmeye tekrar tıklanırsa kök rotaya dön
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: isOwnerMode
            ? [
                // ARAÇ SAHİBİ (Owner) Modu Sekmeleri
                const NavigationDestination(
                  icon: Icon(Icons.car_rental_outlined),
                  selectedIcon: Icon(Icons.car_rental_rounded),
                  label: AppStrings.navMyListings, // İlanlarım
                ),
                const NavigationDestination(
                  icon: Icon(Icons.local_offer_outlined),
                  selectedIcon: Icon(Icons.local_offer_rounded),
                  label: AppStrings.navIncomingOffers, // Gelen Teklifler
                ),
                const NavigationDestination(
                  icon: Icon(Icons.history_rounded),
                  selectedIcon: Icon(Icons.manage_history_rounded),
                  label: AppStrings.navRentalHistory, // Kiralama Geçmişi
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: unreadCount > 0, // Okunmamış mesaj varsa rozet göster
                    label: Text('$unreadCount'),
                    child: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text('$unreadCount'),
                    child: const Icon(Icons.chat_bubble_rounded),
                  ),
                  label: AppStrings.navChats, // Mesajlar
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: AppStrings.navProfile, // Profil
                ),
              ]
            : [
                // KİRACI (Renter) Modu Sekmeleri
                const NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: AppStrings.navExplore, // Keşfet / Ara
                ),
                const NavigationDestination(
                  icon: Icon(Icons.local_fire_department_outlined),
                  selectedIcon: Icon(Icons.local_fire_department_rounded),
                  label: AppStrings.navPopular, // Popüler Araçlar
                ),
                const NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded),
                  label: AppStrings.navMyRentals, // Kiralamalarım
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: unreadCount > 0, // Okunmamış mesaj rozeti
                    label: Text('$unreadCount'),
                    child: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text('$unreadCount'),
                    child: const Icon(Icons.chat_bubble_rounded),
                  ),
                  label: AppStrings.navChats, // Mesajlar
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: AppStrings.navProfile, // Profil
                ),
              ],
      ),
    );
  }
}
