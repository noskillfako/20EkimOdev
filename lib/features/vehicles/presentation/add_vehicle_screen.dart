/// Dosya: lib/features/vehicles/presentation/add_vehicle_screen.dart
/// Görev / İşlev: Araç sahiplerinin 6 adımlı bir Stepper sihirbazı ile (Araç Bilgileri,
/// Teknik Detaylar, Fiyatlandırma, Şehir Konumu, Fotoğraf Seçimi, Önizleme) yeni bir
/// araç ilanını sisteme eklemesini sağlayan form ekranı.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/validators/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';
import 'vehicle_providers.dart';

/// Yeni araç ilanı ekleme formu ekran widget'ı.
class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  int _currentStep = 0;
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Step 1: Info
  String _selectedBrand = 'Renault';
  String _selectedModel = 'Clio';
  final _yearController = TextEditingController(text: '2022');
  String _bodyType = 'hatchback';
  String _fuelType = 'benzin';
  String _transmission = 'otomatik';
  String _color = 'Beyaz';

  // Step 2: Technical
  final _kmController = TextEditingController(text: '45000');
  final _engineCcController = TextEditingController(text: '1332');
  final _widthController = TextEditingController(text: '1798');
  final _weightController = TextEditingController(text: '1240');
  final _seatsController = TextEditingController(text: '5');
  final _consumptionController = TextEditingController(text: '5.4');

  // Step 3: Price & Conditions
  final _dailyPriceController = TextEditingController(text: '1450');
  final _depositController = TextEditingController(text: '5000');
  final _kmLimitController = TextEditingController(text: '300');
  final _descriptionController = TextEditingController(text: 'Temiz, düzenli bakımlı ve sigara içilmemiş araç.');

  // Step 4: Location
  String _selectedCity = 'İstanbul';

  // Step 5: Photos (Selected from available mock assets)
  final List<String> _availablePhotos = [
    'assets/mock/images/car_sedan_red.jpg',
    'assets/mock/images/car_suv_white.jpg',
    'assets/mock/images/car_hatch_blue.jpg',
    'assets/mock/images/car_ev_grey.jpg',
    'assets/mock/images/car_sedan_black.jpg',
    'assets/mock/images/car_wagon_silver.jpg',
  ];
  late List<String> _selectedPhotos;

  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _selectedPhotos = [_availablePhotos[0], _availablePhotos[1], _availablePhotos[2]];
  }

  @override
  void dispose() {
    _yearController.dispose();
    _kmController.dispose();
    _engineCcController.dispose();
    _widthController.dispose();
    _weightController.dispose();
    _seatsController.dispose();
    _consumptionController.dispose();
    _dailyPriceController.dispose();
    _depositController.dispose();
    _kmLimitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Mevcut adımın form doğrulamalarını yapar ve geçerliyse bir sonraki adıma geçer; son adımda ise ilanı yayınlar.
  void _onStepContinue() {
    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      if (!_step2Key.currentState!.validate()) return;
    } else if (_currentStep == 2) {
      if (!_step3Key.currentState!.validate()) return;
    } else if (_currentStep == 4) {
      if (_selectedPhotos.length < 3) {
        AppDialogs.showErrorSnackBar(context, 'Lütfen en az 3 fotoğraf seçiniz.');
        return;
      }
    }

    if (_currentStep < 5) {
      setState(() => _currentStep += 1);
    } else {
      _publishListing();
    }
  }

  /// Bir önceki adıma döner veya ilk adımda ise ekranı kapatır.
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Girilen tüm form verilerini bir Vehicle nesnesine dönüştürerek ilanı sisteme kaydeder.
  Future<void> _publishListing() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() => _isPublishing = true);

    try {
      final catalog = ref.read(vehicleRepositoryProvider).getCatalog();
      final citiesList = (catalog['cities'] as List<dynamic>?) ?? [];
      final cityObj = citiesList.firstWhere(
        (c) => c['name'] == _selectedCity,
        orElse: () => {'lat': 41.0082, 'lng': 28.9784},
      );

      final newVehicle = Vehicle(
        id: 'veh_${DateTime.now().millisecondsSinceEpoch}',
        ownerId: user.id,
        brand: _selectedBrand,
        model: _selectedModel,
        modelYear: int.parse(_yearController.text.trim()),
        km: int.parse(_kmController.text.trim()),
        fuelType: _fuelType,
        bodyType: _bodyType,
        transmission: _transmission,
        color: _color,
        engineCc: int.tryParse(_engineCcController.text.trim()),
        widthMm: int.tryParse(_widthController.text.trim()) ?? 1800,
        weightKg: int.tryParse(_weightController.text.trim()) ?? 1300,
        seats: int.tryParse(_seatsController.text.trim()) ?? 5,
        fuelConsumption: double.tryParse(_consumptionController.text.trim()),
        dailyPrice: int.parse(_dailyPriceController.text.trim()),
        deposit: int.parse(_depositController.text.trim()),
        dailyKmLimit: int.parse(_kmLimitController.text.trim()),
        minRentalDays: 1,
        maxRentalDays: 30,
        city: _selectedCity,
        lat: (cityObj['lat'] as num).toDouble(),
        lng: (cityObj['lng'] as num).toDouble(),
        photos: _selectedPhotos,
        status: 'active',
        description: _descriptionController.text.trim(),
      );

      await ref.read(vehiclesProvider.notifier).addVehicle(newVehicle);
      ref.invalidate(ownerVehiclesProvider);

      if (mounted) {
        AppDialogs.showSuccessSnackBar(context, 'İlanınız başarıyla yayına alındı!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showErrorSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalog = ref.watch(vehicleRepositoryProvider).getCatalog();
    final brandsList = (catalog['brands'] as List<dynamic>?) ?? [];
    final citiesList = (catalog['cities'] as List<dynamic>?) ?? [];

    // Dependent models
    final selectedBrandObj = brandsList.firstWhere(
      (b) => b['name'] == _selectedBrand,
      orElse: () => brandsList.isNotEmpty ? brandsList.first : {'models': []},
    );
    final modelsList = (selectedBrandObj['models'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlan Ver'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 5;
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _isPublishing ? null : details.onStepContinue,
                    child: _isPublishing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isLast ? 'İlanı Yayınla' : 'Devam Et'),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton(
                    onPressed: _isPublishing ? null : details.onStepCancel,
                    child: const Text('Geri'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Step 1: Vehicle Info
          Step(
            title: const Text('Araç Bilgisi'),
            isActive: _currentStep >= 0,
            content: Form(
              key: _step1Key,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBrand,
                    decoration: const InputDecoration(labelText: 'Marka'),
                    items: brandsList
                        .map((b) => DropdownMenuItem(value: b['name'] as String, child: Text(b['name'] as String)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final bObj = brandsList.firstWhere((b) => b['name'] == val);
                        final mList = (bObj['models'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                        setState(() {
                          _selectedBrand = val;
                          _selectedModel = mList.isNotEmpty ? mList.first : '';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: modelsList.contains(_selectedModel) ? _selectedModel : (modelsList.isNotEmpty ? modelsList.first : null),
                    decoration: const InputDecoration(labelText: 'Model'),
                    items: modelsList
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedModel = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _yearController,
                    label: 'Model Yılı',
                    keyboardType: TextInputType.number,
                    validator: Validators.validateModelYear,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _fuelType,
                          decoration: const InputDecoration(labelText: 'Yakıt'),
                          items: const [
                            DropdownMenuItem(value: 'benzin', child: Text('Benzin')),
                            DropdownMenuItem(value: 'dizel', child: Text('Dizel')),
                            DropdownMenuItem(value: 'hibrit', child: Text('Hibrit')),
                            DropdownMenuItem(value: 'elektrik', child: Text('Elektrik')),
                            DropdownMenuItem(value: 'lpg', child: Text('LPG')),
                          ],
                          onChanged: (v) => setState(() => _fuelType = v!),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _transmission,
                          decoration: const InputDecoration(labelText: 'Vites'),
                          items: const [
                            DropdownMenuItem(value: 'otomatik', child: Text('Otomatik')),
                            DropdownMenuItem(value: 'manuel', child: Text('Manuel')),
                          ],
                          onChanged: (v) => setState(() => _transmission = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _bodyType,
                          decoration: const InputDecoration(labelText: 'Kasa'),
                          items: const [
                            DropdownMenuItem(value: 'sedan', child: Text('Sedan')),
                            DropdownMenuItem(value: 'hatchback', child: Text('Hatchback')),
                            DropdownMenuItem(value: 'suv', child: Text('SUV')),
                            DropdownMenuItem(value: 'station_wagon', child: Text('Station')),
                            DropdownMenuItem(value: 'coupe', child: Text('Coupe')),
                          ],
                          onChanged: (v) => setState(() => _bodyType = v!),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _color,
                          decoration: const InputDecoration(labelText: 'Renk'),
                          items: const [
                            DropdownMenuItem(value: 'Beyaz', child: Text('Beyaz')),
                            DropdownMenuItem(value: 'Siyah', child: Text('Siyah')),
                            DropdownMenuItem(value: 'Gri', child: Text('Gri')),
                            DropdownMenuItem(value: 'Gümüş', child: Text('Gümüş')),
                            DropdownMenuItem(value: 'Kırmızı', child: Text('Kırmızı')),
                            DropdownMenuItem(value: 'Mavi', child: Text('Mavi')),
                            DropdownMenuItem(value: 'Füme', child: Text('Füme')),
                          ],
                          onChanged: (v) => setState(() => _color = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Step 2: Technical
          Step(
            title: const Text('Teknik Bilgiler'),
            isActive: _currentStep >= 1,
            content: Form(
              key: _step2Key,
              child: Column(
                children: [
                  AppTextField(
                    controller: _kmController,
                    label: 'Kilometre (KM)',
                    keyboardType: TextInputType.number,
                    validator: Validators.validateKm,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _engineCcController,
                    label: 'Motor Hacmi (cc)',
                    hint: 'Elektrikli ise boş bırakabilirsiniz',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _seatsController,
                          label: 'Koltuk Sayısı',
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          controller: _consumptionController,
                          label: 'Yakıt Tüketimi (L/100km)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Step 3: Price & Conditions
          Step(
            title: const Text('Fiyat & Koşullar'),
            isActive: _currentStep >= 2,
            content: Form(
              key: _step3Key,
              child: Column(
                children: [
                  AppTextField(
                    controller: _dailyPriceController,
                    label: 'Günlük Kiralama Fiyatı (₺)',
                    keyboardType: TextInputType.number,
                    validator: Validators.validatePrice,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _depositController,
                    label: 'Depozito Tutarı (₺)',
                    keyboardType: TextInputType.number,
                    validator: Validators.validatePrice,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _kmLimitController,
                    label: 'Günlük KM Limiti',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Limit giriniz' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Açıklama',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          // Step 4: Location
          Step(
            title: const Text('Konum'),
            isActive: _currentStep >= 3,
            content: DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: const InputDecoration(labelText: 'Araç Konumu (Şehir)'),
              items: citiesList
                  .map((c) => DropdownMenuItem(value: c['name'] as String, child: Text(c['name'] as String)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCity = v);
              },
            ),
          ),

          // Step 5: Photos
          Step(
            title: const Text('Fotoğraflar'),
            isActive: _currentStep >= 4,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'En az 3 fotoğraf seçiniz (İlk seçilen kapak görseli olur):',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 16 / 9,
                  ),
                  itemCount: _availablePhotos.length,
                  itemBuilder: (context, index) {
                    final photo = _availablePhotos[index];
                    final isSelected = _selectedPhotos.contains(photo);
                    final selIdx = _selectedPhotos.indexOf(photo);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            if (_selectedPhotos.length > 3) {
                              _selectedPhotos.remove(photo);
                            } else {
                              AppDialogs.showErrorSnackBar(context, 'En az 3 fotoğraf seçilmelidir.');
                            }
                          } else {
                            _selectedPhotos.add(photo);
                          }
                        });
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            child: Image.asset(photo, fit: BoxFit.cover),
                          ),
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primarySeed.withAlpha(120),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                border: Border.all(color: AppColors.primarySeed, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  selIdx == 0 ? 'Kapak' : '${selIdx + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Step 6: Preview & Publish
          Step(
            title: const Text('Önizleme & Yayın'),
            isActive: _currentStep >= 5,
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedPhotos.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(_selectedPhotos.first, fit: BoxFit.cover),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '$_selectedBrand $_selectedModel (${_yearController.text})',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Konum: $_selectedCity • ${Formatters.formatKm(int.tryParse(_kmController.text) ?? 0)}'),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      Formatters.formatDailyPrice(int.tryParse(_dailyPriceController.text) ?? 0),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Depozito: ${Formatters.formatCurrency(int.tryParse(_depositController.text) ?? 0)}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
