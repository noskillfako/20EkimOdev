import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/chat_repository.dart';
import '../domain/chat.dart';

final userChatsProvider = AsyncNotifierProvider<UserChatsNotifier, List<Chat>>(() {
  return UserChatsNotifier();
});

class UserChatsNotifier extends AsyncNotifier<List<Chat>> {
  @override
  Future<List<Chat>> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return [];
    final repo = ref.watch(chatRepositoryProvider);
    return repo.getChatsForUser(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authControllerProvider).value;
      if (user == null) return [];
      final repo = ref.read(chatRepositoryProvider);
      return repo.getChatsForUser(user.id);
    });
  }

  Future<void> markAsRead(String chatId) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.markChatAsRead(chatId);
    await refresh();
  }
}

final unreadMessageCountProvider = Provider<int>((ref) {
  final chats = ref.watch(userChatsProvider).value ?? [];
  return chats.fold<int>(0, (sum, chat) => sum + chat.unreadCount);
});

final chatDetailProvider = FutureProvider.family<Chat, String>((ref, chatId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatById(chatId);
});
