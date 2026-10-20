# Araç Kiralama Uygulaması (Flutter)

## Amaç
Kullanıcıların kriterlerine göre araç bulup kiralayabildiği, araç sahiplerinin ilan verip
kiralama tekliflerini yönetebildiği, kiralayan ve kiraya veren tarafın birbirini yıldızlayıp
yorumlayabildiği küçük ölçekli mobil uygulama.

## Teknoloji
- Flutter (stable), Dart null-safety
- **Veritabanı / backend yok.** Tüm veri yapay zekanın ürettiği sahte (mock) veridir.
- Veri kaynağı: `assets/mock/*.json` → uygulama açılışında belleğe (`MockStore`) yüklenir
- Kalıcılık (opsiyonel): `shared_preferences` ile yalnızca kullanıcının yaptığı değişiklikler
  (favoriler, yeni ilan, gönderilen teklif, verilen puan, tema) saklanır
- State management: Riverpod
- Navigasyon: go_router
- Model: freezed + json_serializable
- Konum: gerçek GPS yok; araçların `city` ve `lat/lng` alanları mock veridedir, kullanıcı
  sabit bir şehir listesinden konum seçer (mesafe Haversine ile hesaplanır)

## Veri katmanı
Her feature için repository arayüzü vardır; tek implementasyon bellek içidir:
`VehicleRepository`, `AuthRepository`, `UserRepository`, `RentalRepository`,
`ChatRepository`, `ReviewRepository`. UI yalnızca arayüzlerle konuşur; ileride gerçek backend
eklemek sadece provider'daki implementasyonu değiştirmektir.

## Roller
Bir kullanıcı (tek e-posta) iki profile sahip olabilir:
1. **Kiracı (renter):** araç arar, kiralar.
2. **Kiraya veren (owner):** ilan verir, teklifleri yönetir.
Kullanıcı uygulama içinde rol değiştirebilir. İkinci profil için yeniden kayıt gerekmez,
sadece o role ait ek bilgiler tamamlanır.

## Ekranlar

### Ortak
- Splash, onboarding
- Üye kayıt / giriş
- Rol seçimi ve rol değiştirme
- Profil ve profil düzenleme
- Sohbet listesi ve sohbet odası
- Ayarlar (tema)

### Kiracı sahnesi
- Araç filtreleme / arama sayfası
- Popüler ilanlar (ana sayfa)
- İlan detay (araç özellikleri, fiyat, sahibin puanı ve yorumları)
- Teklif gönderme
- Geçmiş kiralama işlemlerim
- Araç sahibini puanlama ve yorum

### Kiraya veren sahnesi
- İlan verme sayfası (çok adımlı form)
- İlanlarım (düzenle, duraklat)
- Gelen teklifler (kabul / red / karşı teklif)
- Şimdiye kadar yaptığım tüm kiralama işlemleri
- Müşteri ile sohbet
- Kiracıyı puanlama ve yorum

## Profil bilgileri
Ad soyad, yaş (doğum tarihinden hesaplanır), meslek grubu, medeni hal, cinsiyet,
kiraladığı / kiraya verdiği araç sayısı (otomatik), sabıka durumu, ortalama puan ve yorum sayısı.

> **Not:** Sabıka bilgisi KVKK kapsamında özel nitelikli veridir. Gerçek bir yayında beyana
> dayalı sayı yerine doğrulanmış belge ve "doğrulandı" rozeti kullanılmalıdır. Bu demo
> sürümünde mock veride `criminalRecordStatus` (verified / none) alanı olarak tutulur.
> Cinsiyet, yaş gibi alanlar filtreleme veya eleme için kullanılmaz.

## Araç ilanı alanları
marka, model, model yılı (araç yaşı buradan türetilir), km, yakıt türü, kasa tipi, vites,
renk, motor hacmi (cc), genişlik (mm), ağırlık (kg), koltuk sayısı, yakıt tüketimi,
günlük fiyat, depozito, günlük km limiti, şehir + lat/lng, fotoğraflar, müsaitlik, açıklama.

Türetilen alanlar (her değişiklikte yeniden hesaplanır): `uniqueRenterCount`,
`completedRentalCount`, `ratingAvg`, `ratingCount`, `popularityScore`.

## Filtreler
Araç yaşı, fiyat, araç km, konum (yarıçap), marka, model, yakıt türü, kasa tipi,
işlem geçmişi (min. tamamlanmış kiralama), kiralama süresi, yakıt tüketimi, renk,
motor hacmi, genişlik, ağırlık, kaç kişi tarafından kiralandığı.

Önerilen ek filtreler: vites tipi, koltuk sayısı, minimum sahip puanı, müsait tarih aralığı,
depozito aralığı, km limiti, bagaj hacmi.

## Kiralama akışı
Teklif gönder → sohbet ve pazarlık → kiraya veren onaylar → kiralama aktif →
teslim/iade onayı → tamamlandı → karşılıklı puan ve yorum.

## Puanlama kuralları
- Sadece tamamlanmış kiralama için, her iki taraf da bir kez puan verebilir.
- 1–5 yıldız + isteğe bağlı yorum (max 500 karakter).
- Ortalamalar puan eklenince anında yeniden hesaplanır.

## Veri modeli (Dart sınıfları)
`AppUser`, `RenterProfile`, `OwnerProfile`, `Vehicle`, `Rental`, `Review`, `Chat`, `Message`, `Offer`

## Klasör yapısı
```
lib/
  core/        (tema, router, widgets, validators, dialogs, utils)
  features/
    auth/ profile/ vehicles/ search/ rentals/ chat/ reviews/
      data/ domain/ presentation/
assets/mock/   (users, vehicles, rentals, reviews, chats, catalog .json)
```

## Yol haritası
1. Modeller + mock JSON + in-memory repository'ler
2. Sahte giriş/kayıt + rol sistemi + profil
3. Araç listesi + filtreleme + popüler ilanlar
4. İlan verme + teklif + sahte sohbet
5. Kiralama akışı + puan/yorum
6. Cilalama ve test

## Skill'ler
Her görevden önce `.agent/skills/` altındaki ilgili SKILL.md okunmalıdır.