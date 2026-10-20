import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/validators/validators.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/user_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _professionController;
  late String _maritalStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _professionController = TextEditingController(text: user?.profession ?? '');
    _maritalStatus = user?.maritalStatus ?? 'Bekar';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final updated = user.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        profession: _professionController.text.trim(),
        maritalStatus: _maritalStatus,
      );

      final repo = ref.read(userRepositoryProvider);
      await repo.updateProfile(updated);
      ref.read(authControllerProvider.notifier).updateUserData(updated);

      if (mounted) {
        AppDialogs.showSuccessSnackBar(context, 'Profil bilgileriniz güncellendi.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showErrorSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Ad Soyad',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.validateFullName,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _phoneController,
                  label: 'Telefon Numarası',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _professionController,
                  label: 'Meslek',
                  prefixIcon: Icons.work_outline_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Meslek giriniz' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _maritalStatus,
                  decoration: const InputDecoration(labelText: 'Medeni Hal'),
                  items: const [
                    DropdownMenuItem(value: 'Bekar', child: Text('Bekar')),
                    DropdownMenuItem(value: 'Evli', child: Text('Evli')),
                  ],
                  onChanged: (v) => setState(() => _maritalStatus = v!),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppPrimaryButton(
                  text: 'Değişiklikleri Kaydet',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
