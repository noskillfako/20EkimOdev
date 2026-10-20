import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/data/mock_store.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

// Uygulamanın ana başlangıç noktası (Entry point)
void main() async {
  // Flutter motoru ve widget bağlayıcılarını başlatıyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // Bellek içi (In-Memory) mock veri deposunu assets/*.json dosyalarından okuyup belleğe yüklüyoruz
  final mockStore = await MockStore.loadFromAssets();

  // Riverpod ProviderScope ile tüm uygulamayı sarıyoruz ve mockStore nesnesini enjekte ediyoruz
  runApp(
    ProviderScope(
      overrides: [
        // mockStoreProvider sağlayıcısını oluşturduğumuz mockStore örneğiyle eziyoruz
        mockStoreProvider.overrideWithValue(mockStore),
      ],
      child: const AracKiralamaApp(),
    ),
  );
}

// Uygulamanın kök widget'ı
class AracKiralamaApp extends ConsumerWidget {
  const AracKiralamaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SharedPreferences ile saklanan aktif tema modunu (Sistem / Açık / Koyu) dinliyoruz
    final themeMode = ref.watch(themeModeProvider);

    // GoRouter tabanlı yönlendiriciyi dinliyoruz
    final router = ref.watch(appRouterProvider);

    // Material Design 3 destekli MaterialApp.router
    return MaterialApp.router(
      title: AppStrings.appName, // Uygulama başlığı ('OtoKirala')
      debugShowCheckedModeBanner: false, // Debug bandını gizle
      theme: AppTheme.light, // Açık tema konfigürasyonu
      darkTheme: AppTheme.dark, // Koyu tema konfigürasyonu
      themeMode: themeMode, // Aktif tema modu seçimi
      routerConfig: router, // GoRouter navigasyon konfigürasyonu
    );
  }
}
