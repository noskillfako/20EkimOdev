/// Dosya: lib/features/chat/presentation/chat_room_screen.dart
/// Görev / İşlev: İki kullanıcı arasındaki canlı mesajlaşma ve interaktif teklif pazarlığı ekranıdır (Chat Room).
/// Standart metin mesajlarının yanı sıra kiralama teklif kartlarını (tarih, toplam tutar, onay durumu)
/// görüntüler; araç sahibi için 'Kabul Et' / 'Reddet' aksiyonları ve yeni teklif verme alt sayfası sunar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/states.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/data/user_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/chat_repository.dart';
import '../domain/chat.dart';
import 'chat_providers.dart';

// İki kullanıcı arasında mesajlaşma ve kiralama teklifi alışverişi sağlayan Sohbet Odası Ekranı
class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId; // İlgili sohbetin benzersiz kimliği

  const ChatRoomScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _textController = TextEditingController(); // Mesaj yazma kutusu kontrolcüsü
  final _scrollController = ScrollController(); // Mesaj listesi kaydırma kontrolcüsü
  bool _isSending = false; // Mesaj gönderim animasyonu/durumu

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Yeni mesaj eklendiğinde listenin en altına yumuşak kaydıran fonksiyon
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Normal metin veya teklif kartı mesajı gönderme işlemi
  Future<void> _handleSendMessage({Offer? offer}) async {
    final text = _textController.text.trim();
    if (text.isEmpty && offer == null) return;

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() => _isSending = true);
    final repo = ref.read(chatRepositoryProvider);

    try {
      // Mesajı depoya kaydet
      await repo.sendMessage(
        chatId: widget.chatId,
        senderId: user.id,
        text: offer != null ? '${Formatters.formatCurrency(offer.totalPrice)} kiralama teklifi iletildi.' : text,
        offer: offer,
      );

      _textController.clear(); // Metin kutusunu temizle
      ref.invalidate(chatDetailProvider(widget.chatId)); // Sohbet detay sağlayıcısını yenile
      ref.read(userChatsProvider.notifier).refresh(); // Sohbet listesini yenile
      _scrollToBottom(); // En alta kaydır
    } catch (e) {
      if (mounted) AppDialogs.showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // Sohbet içinden yeni kiralama teklifi hazırlama alt sayfası (BottomSheet)
  Future<void> _showNewOfferSheet(Chat chat, dynamic vehicle) async {
    DateTimeRange? pickedRange = DateTimeRange(
      start: DateTime.now().add(const Duration(days: 2)),
      end: DateTime.now().add(const Duration(days: 5)),
    );

    int dailyPrice = vehicle.dailyPrice;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final days = pickedRange != null ? pickedRange!.duration.inDays : 1;
            final totalPrice = days * dailyPrice;

            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Kiralama Teklifi Hazırla',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${vehicle.title} için tarih ve teklif tutarınızı belirleyin.'),
                  const SizedBox(height: AppSpacing.lg),
                  // Tarih aralığı seçici kartı
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    leading: const Icon(Icons.date_range_rounded),
                    title: Text(pickedRange != null
                        ? '${Formatters.formatDate(pickedRange!.start)} - ${Formatters.formatDate(pickedRange!.end)}'
                        : 'Tarih Seçiniz'),
                    subtitle: Text('$days Günlük Kiralama'),
                    trailing: const Icon(Icons.edit_calendar_rounded),
                    onTap: () async {
                      final res = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 120)),
                        initialDateRange: pickedRange,
                      );
                      if (res != null) {
                        setSheetState(() => pickedRange = res);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Günlük Fiyat Özeti
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Günlük Teklif:'),
                      Text(
                        Formatters.formatDailyPrice(dailyPrice),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Toplam Tutar Özeti
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Toplam Tutar:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        Formatters.formatCurrency(totalPrice),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Teklifi Gönder Butonu
                  FilledButton(
                    onPressed: () {
                      if (pickedRange == null) return;
                      Navigator.of(ctx).pop();
                      final offer = Offer(
                        startDate: pickedRange!.start.toIso8601String().split('T').first,
                        endDate: pickedRange!.end.toIso8601String().split('T').first,
                        dailyPrice: dailyPrice,
                        totalPrice: totalPrice,
                        status: 'pending',
                      );
                      _handleSendMessage(offer: offer);
                    },
                    child: const Text('Teklifi Gönder'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;
    final chatAsync = ref.watch(chatDetailProvider(widget.chatId));
    final vehicleRepo = ref.watch(vehicleRepositoryProvider);
    final userRepo = ref.watch(userRepositoryProvider);

    return chatAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: AppErrorState(message: err.toString())),
      data: (chat) {
        if (user == null) return const SizedBox.shrink();
        // Karşı tarafın ID'sini belirle (Ben kiracıysam araç sahibi, araç sahibiysem kiracı)
        final counterPartId = chat.renterId == user.id ? chat.ownerId : chat.renterId;

        return FutureBuilder(
          future: Future.wait([
            vehicleRepo.getVehicleById(chat.vehicleId),
            userRepo.getUserById(counterPartId),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final vehicle = snapshot.data![0];
            final counterUser = snapshot.data![1];

            return Scaffold(
              // Üst Bilgi Başlığı (Karşı kullanıcının adı ve araç başlığı)
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(counterUser.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '${vehicle.title} • ${Formatters.formatDailyPrice(vehicle.dailyPrice)}',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  // Güvenlik ve Dolandırıcılık Önleme Uyarı Bandı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    color: AppColors.warning.withAlpha(25),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 16, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Güvenliğiniz için telefon ve IBAN gibi bilgileri paylaşmayınız.',
                            style: theme.textTheme.labelSmall?.copyWith(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mesaj Listesi (Kaydırılabilir)
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: chat.messages.length,
                      itemBuilder: (context, index) {
                        final msg = chat.messages[index];
                        final isMe = msg.senderId == user.id;

                        // Eğer mesaj bir teklif içeriyorsa teklif kartı olarak çiz
                        if (msg.isOffer) {
                          return _buildOfferMessage(context, msg, isMe, chat, user.id);
                        }

                        // Normal metin balonu olarak çiz
                        return _buildTextMessage(theme, msg, isMe);
                      },
                    ),
                  ),

                  // Alt Mesaj Yazma ve Teklif Gönderme Çubuğu
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80))),
                      ),
                      child: Row(
                        children: [
                          // Teklif Hazırla Butonu
                          IconButton(
                            icon: const Icon(Icons.local_offer_rounded),
                            tooltip: 'Teklif Gönder',
                            color: theme.colorScheme.primary,
                            onPressed: () => _showNewOfferSheet(chat, vehicle),
                          ),
                          // Mesaj Giriş Metin Kutusu
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: const InputDecoration(
                                hintText: 'Mesajınızı yazın...',
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              onSubmitted: (_) => _handleSendMessage(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Gönder İkon Butonu
                          IconButton.filled(
                            icon: const Icon(Icons.send_rounded),
                            onPressed: _isSending ? null : () => _handleSendMessage(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Standart sohbet metin balonu oluşturan widget
  Widget _buildTextMessage(ThemeData theme, Message msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // Gönderene göre sağa ya da sola yasla
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.formatDateString(msg.createdAt).split(' ').take(2).join(' '),
              style: TextStyle(
                color: (isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant).withAlpha(160),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // İnteraktif Kiralama Teklif Kartı Widget'ı (Onayla, Reddet ve Durum Rozeti içerir)
  Widget _buildOfferMessage(BuildContext context, Message msg, bool isMe, Chat chat, String currentUserId) {
    final theme = Theme.of(context);
    final offer = msg.offer!;
    final isRecipient = msg.senderId != currentUserId; // Teklif bana mı geldi?

    // Teklif durumuna göre renk ve metin belirleme
    Color statusColor;
    String statusText;
    switch (offer.status) {
      case 'accepted':
        statusColor = AppColors.success;
        statusText = 'Teklif Kabul Edildi';
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = 'Teklif Reddedildi';
        break;
      case 'countered':
        statusColor = AppColors.warning;
        statusText = 'Karşı Teklif';
        break;
      default:
        statusColor = AppColors.warning;
        statusText = 'Onay Bekliyor';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withAlpha(120), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teklif Başlığı ve Durum Rozeti
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_offer_rounded, size: 18, color: statusColor),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Kiralama Teklifi', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Tarih Aralığı
            Text(
              'Tarihler: ${Formatters.formatDateString(offer.startDate)} - ${Formatters.formatDateString(offer.endDate)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            // Teklif Tutarı
            Text(
              'Toplam Teklif: ${Formatters.formatCurrency(offer.totalPrice)} (${Formatters.formatDailyPrice(offer.dailyPrice)})',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Teklif beklemedeyse ve alıcı bensem: Reddet ve Kabul Et aksiyon butonları
            if (offer.isPending && isRecipient) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                      onPressed: () async {
                        final repo = ref.read(chatRepositoryProvider);
                        await repo.updateOfferStatus(
                          chatId: chat.id,
                          messageId: msg.id,
                          newStatus: 'rejected', // Teklifi reddet
                          actingUserId: currentUserId,
                        );
                        ref.invalidate(chatDetailProvider(widget.chatId));
                      },
                      child: const Text('Reddet'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                      onPressed: () async {
                        final repo = ref.read(chatRepositoryProvider);
                        await repo.updateOfferStatus(
                          chatId: chat.id,
                          messageId: msg.id,
                          newStatus: 'accepted', // Teklifi kabul et (Otomatik rezervasyon oluşturur)
                          actingUserId: currentUserId,
                        );
                        ref.invalidate(chatDetailProvider(widget.chatId));
                        if (context.mounted) {
                          AppDialogs.showSuccessSnackBar(context, 'Teklif kabul edildi ve rezervasyon oluşturuldu!');
                        }
                      },
                      child: const Text('Kabul Et'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
