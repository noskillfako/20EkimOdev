// Form alanları için doğrulama ve validasyon fonksiyonları sınıfı
class Validators {
  // Sınıfın dışarıdan örneklenmesini engellemek için private yapıcı
  Validators._();

  // E-posta adresi doğrulaması (Boşluk kontrolü, format ve artı etiketli e-postalar için regex)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi boş bırakılamaz'; // Boş girilirse hata dön
    }
    // Standart RFC uyumlu e-posta deseni
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz'; // Format hatalıysa
    }
    return null; // Geçerli
  }

  // Güçlü şifre doğrulaması (En az 8 karakter, en az bir harf ve bir rakam)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz';
    }
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }
    // Harf ve rakam kontrolü
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasLetter || !hasDigit) {
      return 'Şifre en az bir harf ve bir rakam içermelidir';
    }
    return null;
  }

  // Şifre tekrarı eşleşme doğrulaması
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı boş bırakılamaz';
    }
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }

  // Ad Soyad doğrulaması (Türkçe karakter desteği ve en az 2 karakter)
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ad soyad boş bırakılamaz';
    }
    if (value.trim().length < 2) {
      return 'Ad soyad en az 2 karakter olmalıdır';
    }
    // Sadece Türkçe ve İngilizce harfler ile boşluk kabul edilir
    final nameRegex = RegExp(r'^[a-zA-ZçğıöşüÇĞİÖŞÜ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Ad soyad yalnızca harf içerebilir';
    }
    return null;
  }

  // Telefon numarası doğrulaması (Rakam harici karakterleri temizleyip 10 hane kontrolü yapar)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası boş bırakılamaz';
    }
    // Rakam dışı tüm karakterleri ayıkla
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Geçerli bir 10 haneli telefon numarası giriniz';
    }
    return null;
  }

  // Doğum tarihi ve 18 yaş kontrolü
  static String? validateBirthDate(DateTime? date) {
    if (date == null) {
      return 'Doğum tarihi seçilmelidir';
    }
    final now = DateTime.now();
    int age = now.year - date.year;
    // Doğum günü bu yıl henüz gelmediyse yaş bir düşürülür
    if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
      age--;
    }
    if (age < 18) {
      return 'Kiralama hizmetleri için en az 18 yaşında olmalısınız';
    }
    return null;
  }

  // Günlük kiralama fiyatı doğrulaması (Sayısal ve sıfırdan büyük olmalı)
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Fiyat giriniz';
    }
    final numVal = num.tryParse(value.trim());
    if (numVal == null || numVal <= 0) {
      return 'Fiyat 0\'dan büyük bir sayı olmalıdır';
    }
    return null;
  }

  // Kilometre doğrulaması (0 ile 1.000.000 km arasında olmalı)
  static String? validateKm(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kilometre bilgisi giriniz';
    }
    final numVal = num.tryParse(value.trim());
    if (numVal == null || numVal < 0 || numVal > 1000000) {
      return '0 ile 1.000.000 arasında geçerli km giriniz';
    }
    return null;
  }

  // Model yılı doğrulaması (1990 ile gelecek yıl arasında olmalı)
  static String? validateModelYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Model yılı giriniz';
    }
    final year = int.tryParse(value.trim());
    final currentYear = DateTime.now().year;
    if (year == null || year < 1990 || year > currentYear + 1) {
      return '1990 ile ${currentYear + 1} arasında geçerli bir yıl giriniz';
    }
    return null;
  }

  // Türkiye plaka formatı doğrulaması (01-81 il kodu, harf grubu ve sayı grubu)
  static String? validatePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Plaka giriniz';
    }
    // Boşlukları temizle ve büyük harfe çevir
    final clean = value.trim().replaceAll(' ', '').toUpperCase();
    // Türkiye plaka regex deseni (Örn: 34ABC123, 06A1234)
    final plateRegex = RegExp(r'^(0[1-9]|[1-7][0-9]|8[01])[A-Z]{1,3}\d{2,4}$');
    if (!plateRegex.hasMatch(clean)) {
      return 'Geçerli bir Türkiye plakası giriniz (Örn: 34ABC123)';
    }
    return null;
  }

  // Yorum metni uzunluk doğrulaması (En fazla 500 karakter)
  static String? validateComment(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Yorum en fazla 500 karakter olabilir';
    }
    return null;
  }
}
