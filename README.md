# OtoKirala - Araç Kiralama Mobil Uygulaması (Flutter)

Modern, güvenilir, çift rollü (Kiracı & Kiraya Veren) araç kiralama mobil uygulaması. Material Design 3 prensipleri, zengin kullanıcı arayüzü ve akıcı mikro animasyonlarla Flutter ve Riverpod mimarisi üzerine inşa edilmiştir.

> **Önemli Not:** Bu uygulamada kullanılan tüm veriler (kullanıcılar, araçlar, kiralamalar, yorumlar, mesajlar) demo ve test amaçlı üretilmiş **sahte (mock) verilerdir**. Gerçek kişi, araç veya finansal bilgi içermez.

---

## 🚀 Hazır Demo Giriş Bilgileri

Uygulama açılışında tek tıkla test edebileceğiniz veya manuel girebileceğiniz hazır hesaplar:

| Rol | E-posta | Şifre | Profil Bilgisi |
|---|---|---|---|
| **Kiracı (Renter)** | `kiraci@test.com` | `password123` | Ali Yılmaz (Yazılım Mühendisi, İstanbul) |
| **Kiraya Veren (Owner)** | `sahip@test.com` | `password123` | Mehmet Demir (Mimar, İstanbul) |
| **Çift Rol (Her İkisi)** | `ikisi@test.com` | `password123` | Ayşe Kaya (Doktor, İstanbul) |

*Giriş ekranında yer alan **"Hızlı Demo Girişi"** butonlarına tıklayarak şifre yazmadan anında giriş yapabilirsiniz.*

---

## 🌟 Öne Çıkan Özellikler

### 1. 🔄 Çift Rollü Profil ve Anlık Rol Değişimi
- Aynı kullanıcı hesabı ile hem **Kiracı** hem **Kiraya Veren** profili yönetimi.
- Profil sayfasından tek dokunuşla rol değiştirme; alt navigasyon çubuğu ve ekranlar anında güncellenir.
- Rol bazlı ayrı puanlama: Kiracı Puanı ve Araç Sahibi Puanı.
- KVKK uyumlu simüle edilmiş Adli Sicil Doğrulama Rozeti (`verified`).

### 2. 🔍 İleri Düzey Araç Arama ve Filtreleme
- **Haversine Algoritması ile Konum Filtresi:** Seçilen şehir merkezi ile araç konumu arasındaki kuş uçuşu mesafeyi hesaplar ve belirlenen yarıçap (km) içindeki araçları listeler.
- **Detaylı Kriterler:**
  - Günlük Fiyat Aralığı (₺)
  - Araç Yaşı (Yıl)
  - Kilometre Aralığı
  - Marka & Markaya Bağımlı Model Seçimi
  - Yakıt Türü (Benzin, Dizel, Hibrit, Elektrik, LPG)
  - Vites Tipi (Otomatik, Manuel)
  - Kasa Tipi (Sedan, Hatchback, SUV, Station Wagon, Coupe)
  - Renk Seçimi
  - Minimum Tamamlanmış Kiralama Geçmişi
  - Minimum Sahip / Araç Puanı
- Canlı sonuç sayacı (`Sonuçları Göster (N)`) ve filtre rozeti.
- Farklı sıralama opsiyonları: Önerilen, Fiyat (Artan/Azalan), En Yeni, En Yüksek Puan, En Popüler.

### 3. ⭐ Popüler İlanlar ve Dinamik Popülerlik Puanı
- Araçların popülerlik puanı dinamik formülle hesaplanır:
  $$\text{Popülerlik} = (\text{Tamamlanan Kiralama} \times 3) + (\text{Ortalama Puan} \times 10) + (\text{Tekil Kiracı Sayısı} \times 2)$$
- Haftanın en çok tercih edilen ve öne çıkan araçları vitrinde sergilenir.

### 4. 🚗 Çok Adımlı İlan Verme (Kiraya Veren)
- 6 adımlı rehberli ilan sihirbazı:
  1. Araç Bilgisi (Marka, model, model yılı, yakıt, vites, kasa, renk)
  2. Teknik Özellikler (KM, motor hacmi, koltuk, tüketim)
  3. Fiyat & Koşullar (Günlük fiyat, depozito, günlük km limiti, açıklama)
  4. Konum Seçimi (Şehir ve otomatik koordinat eşleme)
  5. Fotoğraf Galerisi (Kapak görseli belirleme, en az 3 fotoğraf kuralı)
  6. Önizleme ve Yayına Alma
- İlan durumları yönetimi: Yayında / Duraklatıldı toggle anahtarı.

### 5. 💬 Canlı Sohbet, Teklif Pazarlığı ve Simülasyon
- Kiracı ilan detayından tarih aralığı seçerek teklif verir.
- Otomatik sohbet odası açılır; teklif mesaj kartı olarak listelenir.
- **Simüle Edilmiş Yanıt Sistemi:** Kullanıcı mesaj veya teklif gönderdikten 1-2 saniye sonra mock araç sahibi gerçekçi yanıt verir (%70 kabul, %30 karşı teklif simülasyonu).
- Teklif onaylandığında anında aktif kiralama kaydı oluşturulur.
- Güvenlik uyarı afişi: *"Telefon ve IBAN gibi kişisel bilgilerinizi paylaşmayınız."*
- Okunmamış mesaj bildirim rozetleri.

### 6. 📝 Karşılıklı Değerlendirme & Yorum Sistemi
- Yalnızca durumu `completed` (tamamlandı) olan kiralamalar için değerlendirme açılır.
- Kiracı: Araç sahibine ve araca 1–5 yıldız ve yorum verir.
- Kiraya Veren: Kiracının özenine 1–5 yıldız ve yorum verir.
- Verilen her puan sonrasında hedef kullanıcının ve aracın ortalama puanı (`ratingAvg`) ve yorum sayısı anında yeniden hesaplanır.
- Mükerrer puanlama engellenmiştir (her kiralama için bir kez puan verilebilir).

### 7. 🎨 Material Design 3 & Tasarım Sistemi
- Açık (Light) ve Koyu (Dark) tema desteği (Ayarlar / Profil altından Sistem, Açık veya Koyu seçilebilir).
- Özel renk paleti (Sapphire Blue, Teal Accent, Amber Star, Semantic Emerald).
- `ComponentGalleryScreen`: Butonlar, avatarlar, yıldızlar, diyaloglar ve iskelet yükleyicilerin canlı incelenebildiği tasarım galerisi.

---

## 📁 Proje Klasör Mimarisi

```
lib/
├── core/
│   ├── constants/       # AppStrings (Türkçe metinler), AppRoutes
│   ├── data/            # MockStore (in-memory bellek deposu ve istatistik hesaplayıcı)
│   ├── dialogs/         # AppDialogs (onay pencereleri, puanlama bottom sheet'i, snackbar)
│   ├── router/          # AppRouter (GoRouter ve StatefulShellRoute ile role-based tablar)
│   ├── theme/           # AppTheme (M3 Light/Dark), AppColors, AppTypography, AppSpacing
│   ├── utils/           # Haversine mesafe formülü, Formatters (₺, km, tarih)
│   ├── validators/      # Saf fonksiyon doğrulayıcılar (E-posta, şifre, km, fiyat vb.)
│   └── widgets/         # AppButtons, AppTextField, VehicleCard, UserAvatar, RatingStars, States
├── features/
│   ├── auth/            # Giriş, Kayıt, Splash, AuthController, AppUser modelleri
│   ├── vehicles/        # Araç detay, çok adımlı ilan verme, ilanlarım, popüler ekranlar
│   ├── search/          # Keşfet, arama çubuğu, detaylı filtreleme sheet'i
│   ├── rentals/         # Kiralamalarım, gelen teklifler, geçmiş işlemler, teslim/iade onayı
│   ├── chat/            # Sohbet listesi, sohbet odası, teklif kartları ve simülasyon
│   ├── reviews/         # Puan ve yorum modelleri, review repository
│   ├── profile/         # Profil görünümü, rol değiştirme, profil düzenleme
│   └── gallery/         # Tasarım sistemi bileşen galerisi
assets/
└── mock/                # users.json, vehicles.json, rentals.json, reviews.json, chats.json, catalog.json
    └── images/          # Yüksek çözünürlüklü stüdyo araç fotoğrafları
test/
├── unit_test.dart       # Validatör, Haversine ve Filtreleme birim testleri
└── widget_test.dart     # Buton, Avatar ve Yıldız bileşen testleri
```

---

## 🛠️ Kurulum ve Çalıştırma

### Bağımlılıkları Yükleme
```bash
flutter pub get
```

### Kod Analizi ve Lint Kontrolü
```bash
flutter analyze
```

### Testleri Çalıştırma
```bash
flutter test
```

### Uygulamayı Başlatma
macOS üzerinde:
```bash
flutter run -d macos
```

Google Chrome üzerinde:
```bash
flutter run -d chrome
```
