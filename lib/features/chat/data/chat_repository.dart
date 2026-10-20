import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/mock_store.dart';
import '../../rentals/domain/rental.dart';
import '../domain/chat.dart';

abstract class ChatRepository {
  Future<List<Chat>> getChatsForUser(String userId);
  Future<Chat> getChatById(String chatId);
  Future<Chat> getOrCreateChat({
    required String vehicleId,
    required String ownerId,
    required String renterId,
  });
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    Offer? offer,
  });
  Future<void> updateOfferStatus({
    required String chatId,
    required String messageId,
    required String newStatus,
    required String actingUserId,
  });
  Future<void> markChatAsRead(String chatId);
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final store = ref.watch(mockStoreProvider);
  return FakeChatRepository(store);
});

class FakeChatRepository implements ChatRepository {
  final MockStore _store;

  FakeChatRepository(this._store);

  @override
  Future<List<Chat>> getChatsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.chats
        .where((c) => c.ownerId == userId || c.renterId == userId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Chat> getChatById(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final chat = _store.chats.cast<Chat?>().firstWhere(
          (c) => c?.id == chatId,
          orElse: () => null,
        );
    if (chat == null) {
      throw Exception('Sohbet odası bulunamadı.');
    }
    return chat;
  }

  @override
  Future<Chat> getOrCreateChat({
    required String vehicleId,
    required String ownerId,
    required String renterId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final existing = _store.chats.cast<Chat?>().firstWhere(
          (c) =>
              c?.vehicleId == vehicleId &&
              c?.ownerId == ownerId &&
              c?.renterId == renterId,
          orElse: () => null,
        );
    if (existing != null) {
      return existing;
    }

    final newChatId = 'chat_${(_store.chats.length + 1).toString().padLeft(3, '0')}';
    final newChat = Chat(
      id: newChatId,
      vehicleId: vehicleId,
      ownerId: ownerId,
      renterId: renterId,
      lastMessage: 'Sohbet başlatıldı',
      unreadCount: 0,
      updatedAt: DateTime.now().toIso8601String(),
      messages: [],
    );
    _store.chats.insert(0, newChat);
    return newChat;
  }

  @override
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    Offer? offer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final chatIndex = _store.chats.indexWhere((c) => c.id == chatId);
    if (chatIndex == -1) {
      throw Exception('Sohbet bulunamadı.');
    }

    final chat = _store.chats[chatIndex];
    final msgId = 'msg_${chatId}_${chat.messages.length + 1}';
    final now = DateTime.now().toIso8601String();

    final newMessage = Message(
      id: msgId,
      senderId: senderId,
      type: offer != null ? 'offer' : 'text',
      text: text,
      offer: offer,
      createdAt: now,
      read: true,
    );

    final updatedMessages = [...chat.messages, newMessage];
    _store.chats[chatIndex] = chat.copyWith(
      lastMessage: text,
      updatedAt: now,
      messages: updatedMessages,
    );

    // Trigger simulated reply if user sent the message
    _triggerSimulatedReply(chatIndex, senderId, offer);

    return newMessage;
  }

  void _triggerSimulatedReply(int chatIndex, String senderId, Offer? sentOffer) {
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (chatIndex >= _store.chats.length) return;
      final currentChat = _store.chats[chatIndex];
      final isRenterSender = senderId == currentChat.renterId;
      final counterPartId = isRenterSender ? currentChat.ownerId : currentChat.renterId;

      final now = DateTime.now().toIso8601String();
      final replyId = 'msg_${currentChat.id}_${currentChat.messages.length + 1}';

      if (sentOffer != null) {
        // If an offer was sent: 70% accept, 30% counter
        final rand = Random().nextDouble();
        if (rand < 0.70) {
          // Accept offer
          final acceptedOffer = sentOffer.copyWith(status: 'accepted');
          // Update the sent message offer status to accepted
          final lastOfferMsgIndex = currentChat.messages.lastIndexWhere((m) => m.offer != null);
          if (lastOfferMsgIndex != -1) {
            final old = currentChat.messages[lastOfferMsgIndex];
            currentChat.messages[lastOfferMsgIndex] = old.copyWith(offer: acceptedOffer);
          }

          // Create active/pending Rental record
          final newRental = Rental(
            id: 'rent_${(_store.rentals.length + 1).toString().padLeft(3, '0')}',
            vehicleId: currentChat.vehicleId,
            ownerId: currentChat.ownerId,
            renterId: currentChat.renterId,
            startDate: sentOffer.startDate,
            endDate: sentOffer.endDate,
            dailyPrice: sentOffer.dailyPrice,
            totalDays: max(1, (sentOffer.totalPrice / sentOffer.dailyPrice).round()),
            totalPrice: sentOffer.totalPrice,
            deposit: 5000,
            status: 'active',
            createdAt: now,
          );
          _store.rentals.insert(0, newRental);

          final reply = Message(
            id: replyId,
            senderId: counterPartId,
            type: 'text',
            text: 'Harika! Teklifinizi kabul ettim. Rezervasyonunuz oluşturuldu. Araç tesliminde görüşmek üzere!',
            createdAt: now,
            read: false,
          );

          _store.chats[chatIndex] = currentChat.copyWith(
            lastMessage: reply.text,
            unreadCount: currentChat.unreadCount + 1,
            updatedAt: now,
            messages: [...currentChat.messages, reply],
          );
        } else {
          // Counter offer (+10% or adjusted)
          final counterDaily = (sentOffer.dailyPrice * 1.1).round();
          final counterTotal = (sentOffer.totalPrice * 1.1).round();
          final counterOffer = Offer(
            startDate: sentOffer.startDate,
            endDate: sentOffer.endDate,
            dailyPrice: counterDaily,
            totalPrice: counterTotal,
            status: 'countered',
          );

          final reply = Message(
            id: replyId,
            senderId: counterPartId,
            type: 'offer',
            text: 'Tarihler uygun ancak günlük fiyatta biraz güncelleme ile karşı teklifimdir.',
            offer: counterOffer,
            createdAt: now,
            read: false,
          );

          _store.chats[chatIndex] = currentChat.copyWith(
            lastMessage: reply.text,
            unreadCount: currentChat.unreadCount + 1,
            updatedAt: now,
            messages: [...currentChat.messages, reply],
          );
        }
      } else {
        // Normal text message reply
        final standardReplies = [
          'Anladım, araç tamamen bakımlı ve temizdir.',
          'Tabii ki, istediğiniz saatte teslimatı organize edebiliriz.',
          'Harika, başka bir sorunuz olursa lütfen çekinmeden yazın.',
          'Tamamdır, iyi günler dilerim!',
        ];
        final replyText = standardReplies[Random().nextInt(standardReplies.length)];

        final reply = Message(
          id: replyId,
          senderId: counterPartId,
          type: 'text',
          text: replyText,
          createdAt: now,
          read: false,
        );

        _store.chats[chatIndex] = currentChat.copyWith(
          lastMessage: replyText,
          unreadCount: currentChat.unreadCount + 1,
          updatedAt: now,
          messages: [...currentChat.messages, reply],
        );
      }
    });
  }

  @override
  Future<void> updateOfferStatus({
    required String chatId,
    required String messageId,
    required String newStatus,
    required String actingUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final chatIndex = _store.chats.indexWhere((c) => c.id == chatId);
    if (chatIndex == -1) return;

    final chat = _store.chats[chatIndex];
    final msgIndex = chat.messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    final msg = chat.messages[msgIndex];
    if (msg.offer == null) return;

    final updatedOffer = msg.offer!.copyWith(status: newStatus);
    final updatedMsg = msg.copyWith(offer: updatedOffer);

    final updatedList = [...chat.messages];
    updatedList[msgIndex] = updatedMsg;

    // If accepted by user, create rental
    if (newStatus == 'accepted') {
      final now = DateTime.now().toIso8601String();
      final newRental = Rental(
        id: 'rent_${(_store.rentals.length + 1).toString().padLeft(3, '0')}',
        vehicleId: chat.vehicleId,
        ownerId: chat.ownerId,
        renterId: chat.renterId,
        startDate: updatedOffer.startDate,
        endDate: updatedOffer.endDate,
        dailyPrice: updatedOffer.dailyPrice,
        totalDays: max(1, (updatedOffer.totalPrice / updatedOffer.dailyPrice).round()),
        totalPrice: updatedOffer.totalPrice,
        deposit: 5000,
        status: 'active',
        createdAt: now,
      );
      _store.rentals.insert(0, newRental);
    }

    _store.chats[chatIndex] = chat.copyWith(messages: updatedList);
  }

  @override
  Future<void> markChatAsRead(String chatId) async {
    final chatIndex = _store.chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _store.chats[chatIndex] = _store.chats[chatIndex].copyWith(unreadCount: 0);
    }
  }
}
