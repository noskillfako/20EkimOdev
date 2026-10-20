/// Dosya: lib/features/rentals/presentation/incoming_offers_screen.dart
/// Görev / İşlev: Araç sahibine kiracılardan gelen kiralama tekliflerini listeleyen ekrandır (Teklifler Sekmesi).
/// Bekleyen veya karşı teklif durumundaki teklifleri, teklif veren kiracının bilgilerini ve tutarı gösterir;
/// tek tıkla teklifi kabul etme, reddetme veya sohbet odasına giderek pazarlık yapma imkanı sunar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/dialogs/app_dialogs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/domain/chat.dart';
import '../../chat/presentation/chat_providers.dart';
import '../../profile/data/user_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';

// Araç sahibine gelen teklifleri listeleyen ana ekran widget'ı
class IncomingOffersScreen extends ConsumerWidget {
  const IncomingOffersScreen({super.key});

  /// Gelen teklifleri filtreleyen ve listeleyen build fonksiyonu.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;
    final userChatsAsync = ref.watch(userChatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.navIncomingOffers, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: userChatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorState(message: err.toString()),
        data: (chats) {
          if (user == null) return const SizedBox.shrink();

          // Find messages with pending/countered offers where owner is the recipient
          final List<_OfferItem> incomingOffers = [];

          for (final chat in chats) {
            if (chat.ownerId == user.id) {
              for (final msg in chat.messages) {
                if (msg.offer != null && (msg.offer!.isPending || msg.offer!.isCountered)) {
                  incomingOffers.add(_OfferItem(chat: chat, message: msg));
                }
              }
            }
          }

          if (incomingOffers.isEmpty) {
            return const AppEmptyState(
              icon: Icons.local_offer_outlined,
              title: 'Bekleyen teklif bulunmuyor',
              subtitle: 'Yeni kiralama teklifleri geldiğinde bu ekranda listelenecektir.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(userChatsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: incomingOffers.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = incomingOffers[index];
                return _IncomingOfferCard(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OfferItem {
  final Chat chat;
  final Message message;

  _OfferItem({required this.chat, required this.message});
}

class _IncomingOfferCard extends ConsumerWidget {
  final _OfferItem item;

  const _IncomingOfferCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userRepo = ref.watch(userRepositoryProvider);
    final vehicleRepo = ref.watch(vehicleRepositoryProvider);
    final chatRepo = ref.watch(chatRepositoryProvider);
    final currentUser = ref.watch(authControllerProvider).value;

    final offer = item.message.offer!;

    return FutureBuilder(
      future: Future.wait([
        userRepo.getUserById(item.chat.renterId),
        vehicleRepo.getVehicleById(item.chat.vehicleId),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const AppLoadingShimmer(height: 160, borderRadius: 16);
        }

        final renter = snapshot.data![0];
        final vehicle = snapshot.data![1];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Renter info & Vehicle
                Row(
                  children: [
                    UserAvatar(
                      name: renter.name,
                      radius: 20,
                      isVerified: renter.isCriminalRecordVerified,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(renter.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${vehicle.title} için teklif verdi',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      tooltip: 'Sohbete Git',
                      onPressed: () => context.push(AppRoutes.chatRoomPath(item.chat.id)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),

                // Offer details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Talep Edilen Tarihler:', style: theme.textTheme.labelSmall),
                        Text(
                          '${Formatters.formatDateString(offer.startDate)} - ${Formatters.formatDateString(offer.endDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Önerilen Tutar:', style: theme.textTheme.labelSmall),
                        Text(
                          Formatters.formatCurrency(offer.totalPrice),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Action buttons (Accept / Reject)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        onPressed: () async {
                          final confirm = await AppDialogs.showConfirmDialog(
                            context: context,
                            title: 'Teklifi Reddet',
                            message: 'Bu teklifi reddetmek istediğinize emin misiniz?',
                            confirmText: 'Reddet',
                            isDestructive: true,
                          );
                          if (confirm && currentUser != null) {
                            await chatRepo.updateOfferStatus(
                              chatId: item.chat.id,
                              messageId: item.message.id,
                              newStatus: 'rejected',
                              actingUserId: currentUser.id,
                            );
                            ref.read(userChatsProvider.notifier).refresh();
                            if (context.mounted) {
                              AppDialogs.showInfoDialog(
                                context: context,
                                title: 'Bilgi',
                                message: 'Teklif reddedildi.',
                              );
                            }
                          }
                        },
                        child: const Text('Reddet'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                        onPressed: () async {
                          final confirm = await AppDialogs.showConfirmDialog(
                            context: context,
                            title: 'Teklifi Onayla',
                            message: '${Formatters.formatCurrency(offer.totalPrice)} tutarındaki kiralama teklifini onaylıyor musunuz?',
                            confirmText: 'Onayla ve Rezervasyonu Başlat',
                          );
                          if (confirm && currentUser != null) {
                            await chatRepo.updateOfferStatus(
                              chatId: item.chat.id,
                              messageId: item.message.id,
                              newStatus: 'accepted',
                              actingUserId: currentUser.id,
                            );
                            ref.read(userChatsProvider.notifier).refresh();
                            if (context.mounted) {
                              AppDialogs.showSuccessSnackBar(
                                context,
                                'Teklif onaylandı ve kiralama kaydı oluşturuldu!',
                              );
                            }
                          }
                        },
                        child: const Text('Kabul Et'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
