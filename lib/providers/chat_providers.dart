import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../repositories/chat_repository.dart';

final chatRepositoryProvider =
    Provider<ChatRepository>((ref) => ChatRepository());

final messagesProvider =
    StreamProvider.family<List<Message>, String>((ref, requestId) {
  return ref.watch(chatRepositoryProvider).watchMessages(requestId);
});
