import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/validators/validators.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _professionController = TextEditingController(text: 'Yazılım Mühendisi');

  DateTime? _selectedBirthDate = DateTime(1996, 6, 15);
  String _maritalStatus = 'Bekar';
  String _gender = 'Erkek';
  String _selectedRoleOption = 'renter'; // 'renter', 'owner', 'both'
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final birthDateError = Validators.validateBirthDate(_selectedBirthDate);
    if (birthDateError != null) {
      AppDialogs.showErrorSnackBar(context, birthDateError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final roles = _selectedRoleOption == 'both'
          ? ['renter', 'owner']
          : [_selectedRoleOption];

      await ref.read(authControllerProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            birthDate: _selectedBirthDate!.toIso8601String().split('T').first,
            profession: _professionController.text.trim(),
            maritalStatus: _maritalStatus,
            gender: _gender,
            roles: roles,
          );

      if (!mounted) return;
      AppDialogs.showSuccessSnackBar(context, 'Kayıt başarılı! Hoş geldiniz.');
      if (roles.contains('owner') && _selectedRoleOption == 'owner') {
        context.go(AppRoutes.myListings);
      } else {
        context.go(AppRoutes.explore);
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.register),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Yeni Hesap Oluşturun',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Kriterlerinize uygun araçları kiralayın veya kendi aracınızı listeleyin.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Personal Info
                Text('Kişisel Bilgiler', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _nameController,
                  label: AppStrings.fullName,
                  hint: 'Adınız Soyadınız',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.validateFullName,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: 'ornek@eposta.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _phoneController,
                  label: AppStrings.phone,
                  hint: '5XX XXX XX XX',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: AppSpacing.md),
                // Birth date picker tile
                InkWell(
                  onTap: _pickBirthDate,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.cake_outlined, size: 20),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              _selectedBirthDate != null
                                  ? 'Doğum Tarihi: ${Formatters.formatDate(_selectedBirthDate!)} (${Formatters.calculateUserAge(_selectedBirthDate!.toIso8601String())} yaş)'
                                  : 'Doğum Tarihi Seçiniz',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down_rounded),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _professionController,
                  label: AppStrings.profession,
                  prefixIcon: Icons.work_outline_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Meslek bilgisi giriniz' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Gender & Marital Status
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: const InputDecoration(labelText: AppStrings.gender),
                        items: const [
                          DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                          DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                        ],
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _maritalStatus,
                        decoration: const InputDecoration(labelText: AppStrings.maritalStatus),
                        items: const [
                          DropdownMenuItem(value: 'Bekar', child: Text('Bekar')),
                          DropdownMenuItem(value: 'Evli', child: Text('Evli')),
                        ],
                        onChanged: (v) => setState(() => _maritalStatus = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Role Selection
                Text(AppStrings.selectRole, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'renter',
                      label: Text(AppStrings.roleRenter),
                      icon: Icon(Icons.search_rounded),
                    ),
                    ButtonSegment(
                      value: 'owner',
                      label: Text(AppStrings.roleOwner),
                      icon: Icon(Icons.directions_car_rounded),
                    ),
                    ButtonSegment(
                      value: 'both',
                      label: Text(AppStrings.roleBoth),
                      icon: Icon(Icons.swap_horiz_rounded),
                    ),
                  ],
                  selected: {_selectedRoleOption},
                  onSelectionChanged: (set) => setState(() => _selectedRoleOption = set.first),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Password
                Text('Güvenlik', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: AppStrings.passwordConfirm,
                  prefixIcon: Icons.lock_reset_rounded,
                  isPassword: true,
                  validator: (v) => Validators.validateConfirmPassword(v, _passwordController.text),
                ),
                const SizedBox(height: AppSpacing.xxl),

                AppPrimaryButton(
                  text: 'Kayıt Ol ve Başla',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
