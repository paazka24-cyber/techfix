import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/message.dart';
import '../../providers/auth_providers.dart';
import '../../providers/chat_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/repair_providers.dart';

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

      // Notify the other person
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
      } catch (_) {
        // message is sent; ignore notification errors
      }
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
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                      child: Text('No messages yet. Say hello!'));
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                        isDense: true,
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

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color:
              isMe ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(message.senderName,
                  style: Theme.of(context).textTheme.labelSmall),
            Text(message.text),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: Theme.of(context).textTheme.labelSmall),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    seen ? Icons.done_all : Icons.done,
                    size: 14,
                    color: seen ? const Color(0xFF00C853) : null,
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
