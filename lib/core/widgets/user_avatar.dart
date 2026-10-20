/// Dosya: lib/core/widgets/user_avatar.dart
/// Görev / İşlev: Kullanıcı profil resmini (avatar) veya isimden türetilen baş harfleri (inisyal)
/// yuvarlak daire içinde çizen ve kullanıcının adli sicil / kimlik doğrulama onay rozetini
/// sağ alt köşede yeşil onay ikonuyla sergileyen avatar bileşenidir.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Kullanıcı profil avatarı ve doğrulama rozeti bileşeni
class UserAvatar extends StatelessWidget {
  final String name; // Kullanıcının adı soyadı (Baş harf türetimi için)
  final String? avatarUrl; // İsteğe bağlı profil fotoğrafı URL'i
  final double radius; // Dairenin yarıçap boyutu (px)
  final bool isVerified; // Adli sicil veya kimlik onay rozeti gösterilsin mi

  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 24.0,
    this.isVerified = false,
  });

  /// Kullanıcı adından baş harfleri (inisyal) çıkaran yardımcı fonksiyon.
  /// Örn: 'Ali Yılmaz' -> 'AY', 'Mehmet' -> 'M'
  String _getInitials() {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Avatarı ve varsa onay rozetini (Stack) çizen build metodu.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _getInitials();

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (!isVerified) {
      return avatar;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.scaffoldBackgroundColor,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }
}
