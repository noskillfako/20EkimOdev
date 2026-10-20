/// Dosya: lib/features/gallery/component_gallery_screen.dart
/// Görev / İşlev: Tasarım sistemi (Design System) bileşen galerisi ekranıdır.
/// Uygulamadaki tüm ortak butonlar (Primary, Secondary, Text, Loading), avatar varyasyonları,
/// interaktif/salt-okunur yıldız puanlama, form girdi alanları, aralık kaydırıcıları (RangeSlider),
/// dialog/snackbar tetikleyicileri ve iskelet yüklenme efektlerini (Shimmer) tek sayfada canlı test etmeyi sağlar.

import 'package:flutter/material.dart';
import '../../core/dialogs/app_dialogs.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/states.dart';
import '../../core/widgets/user_avatar.dart';

// Tasarım sistemi bileşen galerisi ekranı
class ComponentGalleryScreen extends StatefulWidget {
  const ComponentGalleryScreen({super.key});

  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  int _interactiveRating = 4; // Canlı yıldız puanlama deneme değeri
  RangeValues _sliderRange = const RangeValues(1000, 4500); // Örnek fiyat kaydırıcı aralığı

  /// Tüm UI bileşenlerini kategorilere ayrılmış bir liste halinde oluşturan build metodu.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bileşen Galerisi (Design System)'),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          _buildHeader(theme, 'Butonlar (AppButtons)'),
          AppPrimaryButton(
            text: 'Birincil Buton (Primary)',
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppPrimaryButton(
            text: 'Yükleniyor Durumu',
            isLoading: true,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSecondaryButton(
            text: 'İkincil Buton (Outlined)',
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextButton(
            text: 'Metin Butonu',
            icon: Icons.touch_app_rounded,
            onPressed: () {},
          ),
          const Divider(height: 32),

          _buildHeader(theme, 'Avatar & Doğrulama Rozeti (UserAvatar)'),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              UserAvatar(name: 'Ali Yılmaz', radius: 24),
              UserAvatar(name: 'Mehmet Demir', radius: 30, isVerified: true),
              UserAvatar(name: 'Ayşe Kaya', radius: 36, isVerified: true),
            ],
          ),
          const Divider(height: 32),

          _buildHeader(theme, 'Yıldız & Puanlama (RatingStars)'),
          const Text('Salt Okunur (Yarım Yıldız Desteği):'),
          const SizedBox(height: 4),
          const RatingStars(rating: 4.5, count: 42, starSize: 22),
          const SizedBox(height: AppSpacing.md),
          const Text('İnteraktif Puanlama:'),
          const SizedBox(height: 4),
          RatingStars(
            rating: _interactiveRating.toDouble(),
            starSize: 28,
            onRatingChanged: (val) => setState(() => _interactiveRating = val),
          ),
          const Divider(height: 32),

          _buildHeader(theme, 'Metin Alanı (AppTextField)'),
          const AppTextField(
            label: 'Örnek Girdi Alanı',
            hint: 'İpucu metni',
            prefixIcon: Icons.edit_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Şifre Alanı',
            isPassword: true,
            prefixIcon: Icons.lock_outline_rounded,
          ),
          const Divider(height: 32),

          _buildHeader(theme, 'Aralık Seçici (RangeSlider)'),
          RangeSlider(
            values: _sliderRange,
            min: 500,
            max: 8000,
            divisions: 20,
            labels: RangeLabels('${_sliderRange.start.toInt()} ₺', '${_sliderRange.end.toInt()} ₺'),
            onChanged: (v) => setState(() => _sliderRange = v),
          ),
          const Divider(height: 32),

          _buildHeader(theme, 'Diyaloglar & Geri Bildirim (AppDialogs)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () => AppDialogs.showSuccessSnackBar(context, 'İşlem başarıyla tamamlandı!'),
                child: const Text('Başarı SnackBar'),
              ),
              FilledButton.tonal(
                onPressed: () => AppDialogs.showErrorSnackBar(context, 'Bir bağlantı hatası meydana geldi!'),
                child: const Text('Hata SnackBar'),
              ),
              FilledButton.tonal(
                onPressed: () => AppDialogs.showConfirmDialog(
                  context: context,
                  title: 'İşlem Onayı',
                  message: 'Bu işlemi onaylamak istiyor musunuz?',
                ),
                child: const Text('Onay Dialogu'),
              ),
              FilledButton.tonal(
                onPressed: () => AppDialogs.showRatingSheet(
                  context: context,
                  targetUserName: 'Mehmet Demir',
                  targetRoleText: 'Araç Sahibi',
                  includeVehicleRating: true,
                ),
                child: const Text('Puanlama Sheet\'i'),
              ),
            ],
          ),
          const Divider(height: 32),

          _buildHeader(theme, 'İskelet & Yükleme (Shimmer)'),
          const AppLoadingShimmer(height: 20),
          const SizedBox(height: 8),
          const AppLoadingShimmer(height: 20, width: 200),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
