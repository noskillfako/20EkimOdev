/// Dosya: lib/features/auth/presentation/login_screen.dart
/// Görev / İşlev: Kullanıcı giriş arayüzüdür (Login Screen).
/// E-posta ve şifre doğrulaması yaparak kullanıcının oturum açmasını sağlar.
/// Hızlı test için önceden tanımlı hazır Demo Kiracı, Demo Araç Sahibi ve Demo Çift Rol
/// butonları ile tek tıkla giriş imkanı sunar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/validators/validators.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import 'auth_controller.dart';

// Kullanıcı Giriş Ekranı (Login Screen)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Form durumunu ve doğrulamalarını denetleyen anahtar
  final _formKey = GlobalKey<FormState>();

  // E-posta ve şifre metin denetleyicileri (Test kolaylığı için varsayılan demo kiracı ile dolu gelir)
  final _emailController = TextEditingController(text: 'kiraci@test.com');
  final _passwordController = TextEditingController(text: 'password123');

  // Giriş işlemi sürerken yüklenme göstergesi durumu
  bool _isLoading = false;

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için controller'ları serbest bırakıyoruz
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Giriş yap butonuna tıklandığında çalışan fonksiyon
  Future<void> _handleLogin() async {
    // Form alanlarının kurallara uygunluğunu denetle
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Riverpod AuthController üzerinden giriş işlemini başlat
      await ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (!mounted) return;

      // Kullanıcının aktif rolüne göre ana sayfaya yönlendir
      final user = ref.read(authControllerProvider).value;
      if (user != null && user.activeRole == 'owner') {
        context.go(AppRoutes.myListings); // Araç sahibi ise ilanlarıma git
      } else {
        context.go(AppRoutes.explore); // Kiracı ise keşfet sayfasına git
      }
    } catch (e) {
      if (mounted) {
        // Hata durumunda kırmızı SnackBar ile kullanıcıyı bilgilendir
        AppDialogs.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hızlı Demo Butonları: Tek tıkla hazır demo kullanıcısı ile giriş yapma yardımcısı
  void _fillQuickDemo(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    _handleLogin(); // Bilgileri doldurup otomatik giriş yap
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Form(
              key: _formKey, // Form doğrulaması için bağlanan anahtar
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Araç İkonu Alanı
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_car_filled_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Başlık
                  Text(
                    'Hoş Geldiniz',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Alt başlık
                  Text(
                    'Devam etmek için hesabınıza giriş yapın',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // E-posta Giriş Alanı
                  AppTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: 'ornek@eposta.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail, // E-posta validatörü
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Şifre Giriş Alanı (Gizle/Göster özellikli)
                  AppTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true, // Şifre maskeleme
                    validator: (v) => v == null || v.isEmpty ? 'Şifre giriniz' : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Giriş Yap Butonu
                  AppPrimaryButton(
                    text: AppStrings.login,
                    onPressed: _handleLogin,
                    isLoading: _isLoading, // Yükleniyor durumu
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Kayıt Ol Yönlendirmesi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabınız yok mu?',
                        style: theme.textTheme.bodyMedium,
                      ),
                      AppTextButton(
                        text: AppStrings.register,
                        onPressed: () => context.push(AppRoutes.register), // Kayıt sayfasına geçiş
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Hızlı Demo Giriş Çipleri (Kiracı, Araç Sahibi ve Çift Rol testleri için)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withAlpha(100),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Demo başlığı
                        Row(
                          children: [
                            Icon(Icons.bolt_rounded, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Hızlı Demo Girişi (Tek Tıkla Dene):',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Çipler: Kiracı, Kiraya Veren, Çift Rol
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.person_rounded, size: 16),
                              label: const Text('Kiracı (Ali Y.)'),
                              onPressed: () => _fillQuickDemo('kiraci@test.com', 'password123'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.car_rental_rounded, size: 16),
                              label: const Text('Kiraya Veren (Mehmet D.)'),
                              onPressed: () => _fillQuickDemo('sahip@test.com', 'password123'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.swap_horiz_rounded, size: 16),
                              label: const Text('Çift Rol (Ayşe K.)'),
                              onPressed: () => _fillQuickDemo('ikisi@test.com', 'password123'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
