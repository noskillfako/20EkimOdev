/// Dosya: lib/core/widgets/app_text_field.dart
/// Görev / İşlev: Uygulama genelinde formlarda kullanılan standart metin giriş kutusu (TextFormField).
/// Şifre gizleme/gösterme (obscureText) butonu, sol/sağ ikonlar, tema uyumlu kenarlıklar ve
/// dinamik validasyon (hata kontrolü) yeteneklerini kapsüller.

import 'package:flutter/material.dart';

// Standartlaştırılmış metin alanı bileşeni
class AppTextField extends StatefulWidget {
  final TextEditingController? controller; // Metin kontrolcüsü
  final String label; // Başlık / etiket metni
  final String? hint; // İpucu metni (placeholder)
  final String? Function(String?)? validator; // Doğrulama fonksiyonu
  final TextInputType keyboardType; // Klavye türü (e-posta, sayı, metin vb.)
  final TextInputAction textInputAction; // Klavye aksiyonu (Sonraki, Tamam vb.)
  final bool isPassword; // Şifre alanı mı (gizleme butonu ekler)
  final IconData? prefixIcon; // Sol baştaki ikon
  final Widget? suffixIcon; // Sağ uçtaki özel widget
  final ValueChanged<String>? onChanged; // Metin değiştikçe tetiklenen callback
  final VoidCallback? onEditingComplete; // Düzenleme bittiğinde tetiklenen callback
  final int maxLines; // Maksimum satır sayısı
  final bool readOnly; // Yalnızca okunabilir mi
  final VoidCallback? onTap; // Tıklandığında çalışacak callback (Örn: Tarih seçici açma)

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onEditingComplete,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  /// Widget'ın durum nesnesini oluşturur.
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // Şifrenin gizli olup olmadığını kontrol eden yerel durum
  bool _obscureText = true;

  /// Metin giriş kutusunu (TextFormField) ve şifre görünürlük ikonunu çizer.
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.isPassword && _obscureText,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : widget.suffixIcon,
      ),
    );
  }
}

