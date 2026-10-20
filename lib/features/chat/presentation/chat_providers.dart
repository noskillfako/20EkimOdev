/// Dosya: lib/features/chat/presentation/chat_providers.dart
/// Görev / İşlev: Kullanıcının sohbet odaları listesini (`userChatsProvider`),
/// toplam okunmamış mesaj rozet sayacını (`unreadMessageCountProvider`) ve
/// tek bir sohbet odasının detayını (`chatDetailProvider`) yöneten Riverpod sağlayıcılarıdır.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/chat_repository.dart';
import '../domain/chat.dart';

// Kullanıcının sohbet listesini asenkron yöneten sağlayıcı
final userChatsProvider = AsyncNotifierProvider<UserChatsNotifier, List<Chat>>(() {
  return UserChatsNotifier();
});

// Sohbet listesi durum bildirimcisi (Notifier)
class UserChatsNotifier extends AsyncNotifier<List<Chat>> {
  /// Aktif kullanıcının tüm sohbet odalarını asenkron olarak çeker.
  @override
  Future<List<Chat>> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return [];
    final repo = ref.watch(chatRepositoryProvider);
    return repo.getChatsForUser(user.id);
  }

  /// Sohbet odaları listesini depodan yeniden çekerek arayüzü günceller.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authControllerProvider).value;
      if (user == null) return [];
      final repo = ref.read(chatRepositoryProvider);
      return repo.getChatsForUser(user.id);
    });
  }

  /// İlgili sohbet odasındaki okunmamış mesaj sayacını sıfırlar ve listeyi tazeler.
  Future<void> markAsRead(String chatId) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.markChatAsRead(chatId);
    await refresh();
  }
}

// Alt navigasyon barındaki 'Sohbet' sekmesinde gösterilecek toplam okunmamış mesaj sayısını hesaplayan sağlayıcı
final unreadMessageCountProvider = Provider<int>((ref) {
  final chats = ref.watch(userChatsProvider).value ?? [];
  return chats.fold<int>(0, (sum, chat) => sum + chat.unreadCount);
});

// Belirtilen sohbet kimliğine (chatId) göre sohbet detaylarını sağlayan aile (family) sağlayıcısı
final chatDetailProvider = FutureProvider.family<Chat, String>((ref, chatId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatById(chatId);
});

