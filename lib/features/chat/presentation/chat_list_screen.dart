/// Dosya: lib/features/chat/presentation/chat_list_screen.dart
/// Görev / İşlev: Kullanıcının tüm mesajlaşmalarını listeleyen ekrandır (Sohbet Sekmesi).
/// Karşı tarafın avatarını (adli sicil onay rozetli), araç marka/modelini, son mesajı,
/// güncellenme tarihini ve okunmamış mesaj rozetini gösterir; tıklandığında sohbet odasına yönlendirir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/data/user_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../domain/chat.dart';
import 'chat_providers.dart';

// Mesajlaşma ve sohbet listesi ekranı
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  /// Kullanıcının sohbetlerini çeken ve listeyi ListView olarak oluşturan build fonksiyonu.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;
    final chatsAsync = ref.watch(userChatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.navChats, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorState(message: err.toString()),
        data: (chats) {
          if (user == null || chats.isEmpty) {
            return const AppEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Henüz mesajlaşmanız bulunmuyor',
              subtitle: 'İlan detayından araç sahibine teklif veya soru göndererek sohbet başlatabilirsiniz.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(userChatsProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _ChatListTile(chat: chat, currentUserId: user.id);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChatListTile extends ConsumerWidget {
  final Chat chat;
  final String currentUserId;

  const _ChatListTile({required this.chat, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final counterPartId = chat.renterId == currentUserId ? chat.ownerId : chat.renterId;
    final userRepo = ref.watch(userRepositoryProvider);
    final vehicleRepo = ref.watch(vehicleRepositoryProvider);

    return FutureBuilder(
      future: Future.wait([
        userRepo.getUserById(counterPartId),
        vehicleRepo.getVehicleById(chat.vehicleId),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            title: Text('Yükleniyor...'),
          );
        }

        final otherUser = snapshot.data![0];
        final vehicle = snapshot.data![1];

        return ListTile(
          onTap: () {
            ref.read(userChatsProvider.notifier).markAsRead(chat.id);
            context.push(AppRoutes.chatRoomPath(chat.id));
          },
          leading: UserAvatar(
            name: otherUser.name,
            radius: 24,
            isVerified: otherUser.isCriminalRecordVerified,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  otherUser.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                Formatters.formatDateString(chat.updatedAt).split(' ').take(2).join(' '),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: chat.unreadCount > 0 ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.directions_car_rounded, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    vehicle.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat.unreadCount > 0 ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                  fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          trailing: chat.unreadCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySeed,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${chat.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
        );
      },
    );
  }
}
