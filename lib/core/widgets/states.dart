/// Dosya: lib/core/widgets/states.dart
/// Görev / İşlev: Uygulama genelinde kullanılan durum geri bildirim widget'larıdır.
/// Veri bulunamadığında gösterilen Boş Durum (AppEmptyState), hata durumunda gösterilen
/// Hata Ekranı (AppErrorState) ve içerik yüklenirken gösterilen İskelet Efekti (AppLoadingShimmer).

import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Liste veya sorgu sonucu boş olduğunda kullanıcıyı bilgilendiren ve yönlendiren widget.
class AppEmptyState extends StatelessWidget {
  final IconData icon; // Ortada gösterilecek büyük sembolik ikon
  final String title; // Ana durum başlığı (Örn: 'Henüz ilanınız bulunmuyor')
  final String? subtitle; // Açıklama alt metni
  final String? actionText; // Opsiyonel yönlendirme buton metni
  final VoidCallback? onAction; // Buton tıklama eylemi

  const AppEmptyState({
    super.key,
    this.icon = Icons.search_off_rounded,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  /// Boş durum görselini, başlığını ve aksiyon butonunu çizer.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// İşlem veya veri çekme sırasında oluşan hataları gösteren ve tekrar deneme seçeneği sunan hata widget'ı.
class AppErrorState extends StatelessWidget {
  final String message; // Hata mesajı metni
  final VoidCallback? onRetry; // 'Tekrar Dene' butonu tıklama eylemi

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  /// Hata ikonu, mesaj metni ve 'Tekrar Dene' butonunu çizer.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bir hata oluştu',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Veriler asenkron olarak yüklenirken kullanıcıya içeriğin yerini gösteren iskelet (Shimmer) kutusu.
class AppLoadingShimmer extends StatelessWidget {
  final double height; // Yükseklik (px)
  final double width; // Genişlik (px, varsayılan sonsuz)
  final double borderRadius; // Köşe yuvarlatma yarıçapı

  const AppLoadingShimmer({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius = 8,
  });

  /// Tema parlaklığına (Açık/Koyu) göre yarı saydam yüklenme kutusunu çizer.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
