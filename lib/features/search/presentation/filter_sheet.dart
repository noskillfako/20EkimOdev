/// Dosya: lib/features/search/presentation/filter_sheet.dart
/// Görev / İşlev: Kullanıcıların fiyat, konum/yarıçap (Haversine), araç yaşı, km,
/// marka/model, yakıt, vites, kasa tipi ve puan kriterlerine göre gelişmiş filtreleme
/// yapabilmelerini sağlayan alt sayfa (BottomSheet) bileşeni.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../../vehicles/presentation/vehicle_providers.dart';
import '../domain/vehicle_filter.dart';
import 'search_providers.dart';

// Gelişmiş Araç Arama ve Filtreleme Alt Sayfası (BottomSheet)
// Fiyat, Konum/Yarıçap (Haversine), Yaş, KM, Marka/Model, Yakıt, Vites, Kasa ve Puan filtrelerini içerir
class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  // Alt sayfayı açmak için statik yardımcı fonksiyon
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const FilterSheet(),
    );
  }

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late VehicleFilter _filter; // Yerel filtre nesnesi kopyası

  // Kaydırıcılar (RangeSlider ve Slider) için yerel durum değişkenleri
  late RangeValues _ageRange; // Araç yaş aralığı (0 - 15)
  late RangeValues _priceRange; // Günlük fiyat aralığı (500 - 8000 ₺)
  late RangeValues _kmRange; // Kilometre aralığı (0 - 250.000 km)
  late RangeValues _engineCcRange; // Motor hacmi aralığı (800 - 3000 cc)
  late RangeValues _widthRange; // Genişlik aralığı (1600 - 2100 mm)
  late RangeValues _weightRange; // Ağırlık aralığı (900 - 2500 kg)
  double _radiusKm = 50.0; // Şehir merkezine göre Haversine arama yarıçapı (km)
  double _maxConsumption = 10.0; // Azami 100km yakıt tüketimi (Litre)
  double _minCompletedRentals = 0; // Minimum tamamlanmış kiralama sayısı
  double _minUniqueRenters = 0; // Minimum farklı kiracı sayısı
  double _minOwnerRating = 0; // Minimum araç ve sahip puanı

  @override
  void initState() {
    super.initState();
    // Riverpod üzerindeki aktif filtreyi yerel duruma kopyalıyoruz
    _filter = ref.read(vehicleFilterProvider);

    _ageRange = RangeValues(_filter.minAge ?? 0, _filter.maxAge ?? 15);
    _priceRange = RangeValues(_filter.minPrice ?? 500, _filter.maxPrice ?? 8000);
    _kmRange = RangeValues(_filter.minKm ?? 0, _filter.maxKm ?? 250000);
    _engineCcRange = RangeValues(
      (_filter.minEngineCc ?? 800).toDouble(),
      (_filter.maxEngineCc ?? 3000).toDouble(),
    );
    _widthRange = RangeValues(
      (_filter.minWidthMm ?? 1600).toDouble(),
      (_filter.maxWidthMm ?? 2100).toDouble(),
    );
    _weightRange = RangeValues(
      (_filter.minWeightKg ?? 900).toDouble(),
      (_filter.maxWeightKg ?? 2500).toDouble(),
    );

    _radiusKm = _filter.radiusKm ?? 50.0;
    _maxConsumption = _filter.maxConsumption ?? 12.0;
    _minCompletedRentals = (_filter.minCompletedRentals ?? 0).toDouble();
    _minUniqueRenters = (_filter.minUniqueRenters ?? 0).toDouble();
    _minOwnerRating = _filter.minOwnerRating ?? 0.0;
  }

  // Değişen kaydırıcı değerlerini filtre nesnesine senkronize eden metot
  void _syncFilterState() {
    setState(() {
      _filter = _filter.copyWith(
        minAge: _ageRange.start > 0 ? _ageRange.start : null,
        maxAge: _ageRange.end < 15 ? _ageRange.end : null,
        minPrice: _priceRange.start > 500 ? _priceRange.start : null,
        maxPrice: _priceRange.end < 8000 ? _priceRange.end : null,
        minKm: _kmRange.start > 0 ? _kmRange.start : null,
        maxKm: _kmRange.end < 250000 ? _kmRange.end : null,
        radiusKm: _filter.centerCity != null ? _radiusKm : null,
        minEngineCc: _engineCcRange.start > 800 ? _engineCcRange.start.toInt() : null,
        maxEngineCc: _engineCcRange.end < 3000 ? _engineCcRange.end.toInt() : null,
        minWidthMm: _widthRange.start > 1600 ? _widthRange.start.toInt() : null,
        maxWidthMm: _widthRange.end < 2100 ? _widthRange.end.toInt() : null,
        minWeightKg: _weightRange.start > 900 ? _weightRange.start.toInt() : null,
        maxWeightKg: _weightRange.end < 2500 ? _weightRange.end.toInt() : null,
        maxConsumption: _maxConsumption < 12.0 ? _maxConsumption : null,
        minCompletedRentals: _minCompletedRentals > 0 ? _minCompletedRentals.toInt() : null,
        minUniqueRenters: _minUniqueRenters > 0 ? _minUniqueRenters.toInt() : null,
        minOwnerRating: _minOwnerRating > 0 ? _minOwnerRating : null,
      );
    });
  }

  // Tüm filtreleri varsayılan değerlere sıfırlayan fonksiyon
  void _clearAll() {
    setState(() {
      _filter = const VehicleFilter();
      _ageRange = const RangeValues(0, 15);
      _priceRange = const RangeValues(500, 8000);
      _kmRange = const RangeValues(0, 250000);
      _engineCcRange = const RangeValues(800, 3000);
      _widthRange = const RangeValues(1600, 2100);
      _weightRange = const RangeValues(900, 2500);
      _radiusKm = 50.0;
      _maxConsumption = 12.0;
      _minCompletedRentals = 0;
      _minUniqueRenters = 0;
      _minOwnerRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalog = ref.watch(vehicleRepositoryProvider).getCatalog(); // Şehir, marka ve model kataloğu
    final allVehicles = ref.watch(vehiclesProvider).value ?? []; // Sistemdeki tüm araçlar

    // Seçili filtrelere uyan araç sayısını anlık olarak hesapla
    final resultCount = _filter.apply(allVehicles).length;

    final brandsList = (catalog['brands'] as List<dynamic>?) ?? [];
    final fuelList = (catalog['fuelTypes'] as List<dynamic>?) ?? [];
    final bodyList = (catalog['bodyTypes'] as List<dynamic>?) ?? [];
    final transList = (catalog['transmissions'] as List<dynamic>?) ?? [];
    final colorList = (catalog['colors'] as List<dynamic>?) ?? [];
    final citiesList = (catalog['cities'] as List<dynamic>?) ?? [];

    // Seçilen markalara bağlı olarak dinamik modelleri belirleme (Dependent Dropdown Mantığı)
    final List<String> availableModels = [];
    if (_filter.brands != null && _filter.brands!.isNotEmpty) {
      for (final b in brandsList) {
        if (_filter.brands!.contains(b['name'])) {
          final mList = (b['models'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
          availableModels.addAll(mList);
        }
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          // Üst Başlık ve Aktif Filtre Sayısı
          appBar: AppBar(
            title: Text(
              '${AppStrings.filters} (${_filter.activeFilterCount})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(), // Kapat
              ),
            ],
          ),
          body: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              // 1. Günlük Fiyat Aralığı (RangeSlider)
              _buildSectionTitle(theme, 'Günlük Fiyat Aralığı (₺)'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Formatters.formatCurrency(_priceRange.start.round()), style: theme.textTheme.labelMedium),
                  Text(Formatters.formatCurrency(_priceRange.end.round()), style: theme.textTheme.labelMedium),
                ],
              ),
              RangeSlider(
                values: _priceRange,
                min: 500,
                max: 8000,
                divisions: 30,
                labels: RangeLabels(
                  Formatters.formatCurrency(_priceRange.start.round()),
                  Formatters.formatCurrency(_priceRange.end.round()),
                ),
                onChanged: (v) {
                  setState(() => _priceRange = v);
                },
                onChangeEnd: (_) => _syncFilterState(),
              ),
              const Divider(height: 32),

              // 2. Şehir ve Haversine Yarıçap Filtresi
              _buildSectionTitle(theme, 'Konum & Mesafe (Haversine)'),
              DropdownButtonFormField<String>(
                initialValue: _filter.centerCity,
                decoration: const InputDecoration(
                  labelText: 'Şehir Seçiniz',
                  prefixIcon: Icon(Icons.location_city_rounded),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tüm Şehirler')),
                  ...citiesList.map((c) => DropdownMenuItem(
                        value: c['name'] as String,
                        child: Text(c['name'] as String),
                      )),
                ],
                onChanged: (val) {
                  if (val == null) {
                    setState(() {
                      _filter = _filter.copyWith(clearCenterCity: true);
                    });
                  } else {
                    final cObj = citiesList.firstWhere((c) => c['name'] == val);
                    setState(() {
                      _filter = _filter.copyWith(
                        centerCity: val,
                        centerLat: (cObj['lat'] as num).toDouble(),
                        centerLng: (cObj['lng'] as num).toDouble(),
                        radiusKm: _radiusKm,
                      );
                    });
                  }
                },
              ),
              // Şehir seçilmişse Yarıçap (km) kaydırıcısını göster
              if (_filter.centerCity != null) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Arama Yarıçapı:', style: theme.textTheme.labelMedium),
                    Text('${_radiusKm.toInt()} km', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _radiusKm,
                  min: 10,
                  max: 200,
                  divisions: 19,
                  label: '${_radiusKm.toInt()} km',
                  onChanged: (v) => setState(() => _radiusKm = v),
                  onChangeEnd: (_) => _syncFilterState(),
                ),
              ],
              const Divider(height: 32),

              // 3. Araç Yaşı Filtresi (0 - 15 Yaş)
              _buildSectionTitle(theme, 'Araç Yaşı (Yıl)'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_ageRange.start.toInt()} yaş', style: theme.textTheme.labelMedium),
                  Text('${_ageRange.end.toInt()} yaş', style: theme.textTheme.labelMedium),
                ],
              ),
              RangeSlider(
                values: _ageRange,
                min: 0,
                max: 15,
                divisions: 15,
                labels: RangeLabels('${_ageRange.start.toInt()}', '${_ageRange.end.toInt()}'),
                onChanged: (v) => setState(() => _ageRange = v),
                onChangeEnd: (_) => _syncFilterState(),
              ),
              const Divider(height: 32),

              // 4. Kilometre Filtresi (0 - 250.000 KM)
              _buildSectionTitle(theme, 'Araç Kilometresi'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Formatters.formatKm(_kmRange.start.round()), style: theme.textTheme.labelMedium),
                  Text(Formatters.formatKm(_kmRange.end.round()), style: theme.textTheme.labelMedium),
                ],
              ),
              RangeSlider(
                values: _kmRange,
                min: 0,
                max: 250000,
                divisions: 25,
                labels: RangeLabels(
                  Formatters.formatKm(_kmRange.start.round()),
                  Formatters.formatKm(_kmRange.end.round()),
                ),
                onChanged: (v) => setState(() => _kmRange = v),
                onChangeEnd: (_) => _syncFilterState(),
              ),
              const Divider(height: 32),

              // 5. Marka Seçimi (FilterChip)
              _buildSectionTitle(theme, 'Marka'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: brandsList.map((b) {
                  final brandName = b['name'] as String;
                  final isSelected = _filter.brands?.contains(brandName) ?? false;
                  return FilterChip(
                    label: Text(brandName),
                    selected: isSelected,
                    onSelected: (selected) {
                      final current = _filter.brands != null ? [..._filter.brands!] : <String>[];
                      if (selected) {
                        current.add(brandName);
                      } else {
                        current.remove(brandName);
                      }
                      setState(() {
                        _filter = _filter.copyWith(brands: current.isEmpty ? null : current);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // 6. Seçili Markalara Bağlı Model Seçimi (FilterChip)
              if (availableModels.isNotEmpty) ...[
                _buildSectionTitle(theme, 'Model'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableModels.map((m) {
                    final isSelected = _filter.models?.contains(m) ?? false;
                    return FilterChip(
                      label: Text(m),
                      selected: isSelected,
                      onSelected: (selected) {
                        final current = _filter.models != null ? [..._filter.models!] : <String>[];
                        if (selected) {
                          current.add(m);
                        } else {
                          current.remove(m);
                        }
                        setState(() {
                          _filter = _filter.copyWith(models: current.isEmpty ? null : current);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              const Divider(height: 32),

              // 7. Yakıt ve Vites Seçimi
              _buildSectionTitle(theme, 'Yakıt & Vites'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fuelList.map((f) {
                  final fStr = f.toString();
                  final isSelected = _filter.fuelTypes?.contains(fStr) ?? false;
                  return FilterChip(
                    label: Text(fStr.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      final current = _filter.fuelTypes != null ? [..._filter.fuelTypes!] : <String>[];
                      if (selected) {
                        current.add(fStr);
                      } else {
                        current.remove(fStr);
                      }
                      setState(() {
                        _filter = _filter.copyWith(fuelTypes: current.isEmpty ? null : current);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: transList.map((t) {
                  final tStr = t.toString();
                  final isSelected = _filter.transmissions?.contains(tStr) ?? false;
                  return FilterChip(
                    label: Text(tStr.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      final current = _filter.transmissions != null ? [..._filter.transmissions!] : <String>[];
                      if (selected) {
                        current.add(tStr);
                      } else {
                        current.remove(tStr);
                      }
                      setState(() {
                        _filter = _filter.copyWith(transmissions: current.isEmpty ? null : current);
                      });
                    },
                  );
                }).toList(),
              ),
              const Divider(height: 32),

              // 8. Kasa Tipi Seçimi
              _buildSectionTitle(theme, 'Kasa Tipi'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: bodyList.map((b) {
                  final bStr = b.toString();
                  final isSelected = _filter.bodyTypes?.contains(bStr) ?? false;
                  return FilterChip(
                    label: Text(bStr.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      final current = _filter.bodyTypes != null ? [..._filter.bodyTypes!] : <String>[];
                      if (selected) {
                        current.add(bStr);
                      } else {
                        current.remove(bStr);
                      }
                      setState(() {
                        _filter = _filter.copyWith(bodyTypes: current.isEmpty ? null : current);
                      });
                    },
                  );
                }).toList(),
              ),
              const Divider(height: 32),

              // 9. Renk Seçimi
              _buildSectionTitle(theme, 'Renk'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colorList.map((c) {
                  final cStr = c.toString();
                  final isSelected = _filter.colors?.contains(cStr) ?? false;
                  return FilterChip(
                    label: Text(cStr),
                    selected: isSelected,
                    onSelected: (selected) {
                      final current = _filter.colors != null ? [..._filter.colors!] : <String>[];
                      if (selected) {
                        current.add(cStr);
                      } else {
                        current.remove(cStr);
                      }
                      setState(() {
                        _filter = _filter.copyWith(colors: current.isEmpty ? null : current);
                      });
                    },
                  );
                }).toList(),
              ),
              const Divider(height: 32),

              // 10. Tamamlanmış Kiralama Sayısı ve Minimum Puan Filtresi
              _buildSectionTitle(theme, 'Kiralama Geçmişi & Sahip Puanı'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Min. Tamamlanmış Kiralama:', style: theme.textTheme.labelMedium),
                  Text('${_minCompletedRentals.toInt()}+', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _minCompletedRentals,
                min: 0,
                max: 10,
                divisions: 10,
                label: '${_minCompletedRentals.toInt()}',
                onChanged: (v) => setState(() => _minCompletedRentals = v),
                onChangeEnd: (_) => _syncFilterState(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Minimum Araç / Sahip Puanı:', style: theme.textTheme.labelMedium),
                  Text(_minOwnerRating > 0 ? '${_minOwnerRating.toStringAsFixed(1)} ★' : 'Farketmez',
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _minOwnerRating,
                min: 0,
                max: 5,
                divisions: 10,
                label: _minOwnerRating.toStringAsFixed(1),
                onChanged: (v) => setState(() => _minOwnerRating = v),
                onChangeEnd: (_) => _syncFilterState(),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
          // Alt Sabit Butonlar (Temizle ve Sonuçları Göster)
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80))),
              ),
              child: Row(
                children: [
                  // Temizle Butonu
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      child: const Text('Temizle'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Sonuçları Göster Butonu (Eşleşen araç sayısı rozeti ile)
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        ref.read(vehicleFilterProvider.notifier).updateFilter(_filter);
                        Navigator.of(context).pop();
                      },
                      child: Text('Sonuçları Göster ($resultCount)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Bölüm başlığı oluşturan yardımcı widget
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
