import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/user_repository.dart';

// Kullanıcı Profil ve Ayarlar Ekranı (Rol değiştirme, İstatistikler, Tema modu ve Çıkış yapma)
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value; // Aktif oturum kullanıcısı
    final themeMode = ref.watch(themeModeProvider); // Aktif tema modu (Sistem/Açık/Koyu)
    final userRepo = ref.watch(userRepositoryProvider); // Kullanıcı verisi sağlayıcısı

    // Giriş yapılmamışsa boş durum ekranı göster
    if (user == null) {
      return Scaffold(
        body: AppEmptyState(
          icon: Icons.person_off_rounded,
          title: 'Oturum Açılmadı',
          actionText: AppStrings.login,
          onAction: () => context.go(AppRoutes.login),
        ),
      );
    }

    final isOwnerMode = user.activeRole == 'owner'; // Kullanıcı şu an araç sahibi modunda mı?
    final userAge = Formatters.calculateUserAge(user.birthDate); // Kullanıcı yaş hesabı

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.navProfile, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          // Profili Düzenle Butonu
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Profili Düzenle',
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
          // Tasarım Bileşen Galerisi Butonu
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Bileşen Galerisi',
            onPressed: () => context.push(AppRoutes.gallery),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // 1. Kullanıcı Profil Kartı (Avatar, Ad Soyad, Doğrulama Rozeti, Meslek, E-posta)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Kullanıcı Avatarı (Baş harfler veya profil resmi)
                  UserAvatar(
                    name: user.name,
                    radius: 40,
                    isVerified: user.isCriminalRecordVerified,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Ad Soyad ve Adli Sicil Doğrulama Rozeti
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (user.isCriminalRecordVerified) ...[
                        const SizedBox(width: 6),
                        const Tooltip(
                          message: 'Adli Sicil Kaydı Doğrulandı',
                          child: Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Meslek ve Yaş Bilgisi
                  Text(
                    '${user.profession} • $userAge yaşında',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // E-posta Adresi
                  Text(user.email, style: theme.textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.lg),

                  // Aktif Rol Rozeti (Kiracı / Kiraya Veren)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(80),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOwnerMode ? Icons.directions_car_rounded : Icons.search_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Aktif Rol: ${isOwnerMode ? "Kiraya Veren" : "Kiracı"}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Tek Tıkla Rol Değiştirme Butonu (Kiracı <-> Kiraya Veren)
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: Text(
                      isOwnerMode ? AppStrings.switchToRenter : AppStrings.switchToOwner,
                    ),
                    onPressed: () async {
                      final targetRole = isOwnerMode ? 'renter' : 'owner';
                      // Rol değiştirme onay kutusu
                      final confirm = await AppDialogs.showConfirmDialog(
                        context: context,
                        title: 'Rol Değiştir',
                        message: isOwnerMode
                            ? 'Kiracı moduna geçmek istiyor musunuz? İlan arayabilir ve kiralayabilirsiniz.'
                            : 'Kiraya veren moduna geçmek istiyor musunuz? İlanlarınızı ve gelen teklifleri yönetebilirsiniz.',
                        confirmText: 'Modu Değiştir',
                      );

                      if (confirm) {
                        // Rolü değiştir
                        await ref.read(authControllerProvider.notifier).switchRole(targetRole);
                        if (context.mounted) {
                          AppDialogs.showSuccessSnackBar(
                            context,
                            '${targetRole == "owner" ? "Kiraya Veren" : "Kiracı"} moduna geçildi!',
                          );
                          // İlgili modun ana sayfasına yönlendir
                          if (targetRole == 'owner') {
                            context.go(AppRoutes.myListings);
                          } else {
                            context.go(AppRoutes.explore);
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Role Göre Dinamik İstatistik Kartları
          Text('İstatistikler', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (isOwnerMode) ...[
                // Araç Sahibi İstatistikleri: Yayında İlan, Kiralatılan Araç Sayısı, Puan
                Expanded(
                  child: _buildStatTile(
                    theme,
                    Icons.directions_car_outlined,
                    '${user.ownerProfile?.listingCount ?? 0}',
                    'Yayında İlan',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatTile(
                    theme,
                    Icons.handshake_outlined,
                    '${user.ownerProfile?.rentedOutCount ?? 0}',
                    'Kiralattı',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatTile(
                    theme,
                    Icons.star_outline_rounded,
                    '${user.ownerProfile?.ratingAvg.toStringAsFixed(1) ?? "5.0"} ★',
                    '${user.ownerProfile?.ratingCount ?? 0} Yorum',
                  ),
                ),
              ] else ...[
                // Kiracı İstatistikleri: Kiralanan Araç Sayısı ve Kiracı Puanı
                Expanded(
                  child: _buildStatTile(
                    theme,
                    Icons.key_rounded,
                    '${user.renterProfile?.rentedCount ?? 0}',
                    'Kiralanan Araç',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatTile(
                    theme,
                    Icons.star_outline_rounded,
                    '${user.renterProfile?.ratingAvg.toStringAsFixed(1) ?? "5.0"} ★',
                    '${user.renterProfile?.ratingCount ?? 0} Puan',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // 3. Tema Seçimi (Sistem / Açık / Koyu SegmentedButton)
          Text('Uygulama Teması', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.brightness_6_rounded, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Görünüm Seçimi', style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('Sistem'),
                          icon: Icon(Icons.settings_suggest_rounded, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Açık'),
                          icon: Icon(Icons.light_mode_rounded, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Koyu'),
                          icon: Icon(Icons.dark_mode_rounded, size: 16),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (modes) {
                        // Tema modunu güncelle ve SharedPreferences'a kaydet
                        ref.read(themeModeProvider.notifier).setThemeMode(modes.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 4. Kullanıcının Aldığı Değerlendirmeler
          Text('Alınan Değerlendirmeler', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder(
            future: userRepo.getUserReviews(user.id, isOwnerMode ? 'owner' : 'renter'),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (!snapshot.hasData) {
                return const AppLoadingShimmer(height: 80, borderRadius: 16);
              }
              final reviews = snapshot.data!;
              if (reviews.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('Henüz değerlendirme bulunmuyor.'),
                  ),
                );
              }

              return Column(
                children: reviews.take(5).map((r) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RatingStars(rating: r.stars.toDouble(), starSize: 14),
                              Text(Formatters.formatDateString(r.createdAt), style: theme.textTheme.labelSmall),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(r.comment, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // 5. Çıkış Yap Butonu
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error.withAlpha(120)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text(AppStrings.logout),
            onPressed: () async {
              final confirm = await AppDialogs.showConfirmDialog(
                context: context,
                title: AppStrings.logout,
                message: 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
                confirmText: 'Çıkış Yap',
                isDestructive: true,
              );
              if (confirm) {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              }
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  // İstatistik kutucuğu oluşturan yardımcı widget
  Widget _buildStatTile(ThemeData theme, IconData icon, String value, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        child: Column(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
