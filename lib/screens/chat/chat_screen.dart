import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/message.dart';
import '../../providers/auth_providers.dart';
import '../../providers/chat_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/repair_providers.dart';
import '../../widgets/empty_state.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String title;
  const ChatScreen({super.key, required this.requestId, required this.title});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  int _lastCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final me = ref.read(appUserProvider).value;
    if (text.isEmpty || me == null) return;
    _controller.clear();
    try {
      await ref.read(chatRepositoryProvider).send(
            Message(
              requestId: widget.requestId,
              senderId: me.uid,
              senderName: me.fullName,
              text: text,
              createdAt: DateTime.now(),
            ),
          );

      try {
        final req = await ref
            .read(repairRepositoryProvider)
            .watchRequest(widget.requestId)
            .first;
        if (req != null) {
          final other =
              me.uid == req.customerId ? req.technicianId : req.customerId;
          if (other != null) {
            await ref.read(notifierProvider).newMessage(
                  toUserId: other,
                  fromUserId: me.uid,
                  senderName: me.fullName,
                  text: text,
                  requestId: widget.requestId,
                );
          }
        }
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(authStateProvider).value?.uid ?? '';
    final messages = ref.watch(messagesProvider(widget.requestId));
    final scheme = Theme.of(context).colorScheme;

    ref.listen(messagesProvider(widget.requestId), (_, next) {
      final list = next.value;
      if (list == null) return;
      ref.read(chatRepositoryProvider).markRead(list, myUid);
      if (list.length != _lastCount) {
        _lastCount = list.length;
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.person,
                  size: 18, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.title, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No messages yet',
                    message: 'Say hello and discuss the repair here.',
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, i) => _Bubble(
                      message: list[i], isMe: list[i].senderId == myUid),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _send,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  const _Bubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final seen = message.readBy.length > 1;
    final t = message.createdAt;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final fg = isMe ? scheme.onPrimary : scheme.onSurface;
    final sub = isMe
        ? scheme.onPrimary.withValues(alpha: 0.75)
        : scheme.onSurfaceVariant;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 7),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.senderName,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: scheme.primary),
                ),
              ),
            Text(message.text, style: TextStyle(color: fg)),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: sub)),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    seen ? Icons.done_all : Icons.done,
                    size: 14,
                    color: seen ? const Color(0xFF69F0AE) : sub,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
