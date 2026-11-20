import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';

class Notifier {
  final NotificationRepository _repo;
  Notifier(this._repo);

  Future<void> _send({
    required String toUserId,
    required String fromUserId,
    required String title,
    required String body,
    String? requestId,
  }) {
    return _repo.create(AppNotification(
      userId: toUserId,
      fromUserId: fromUserId,
      title: title,
      body: body,
      requestId: requestId,
      createdAt: DateTime.now(),
    ));
  }

  // 1. New repair request -> every technician
  Future<void> newRequest({
    required List<String> technicianIds,
    required String fromUserId,
    required String requestId,
    required String device,
  }) async {
    for (final id in technicianIds) {
      await _send(
        toUserId: id,
        fromUserId: fromUserId,
        title: 'New repair request',
        body: 'A customer needs help with: $device',
        requestId: requestId,
      );
    }
  }

  // 2. Request accepted -> customer
  Future<void> requestAccepted({
    required String customerId,
    required String technicianId,
    required String requestId,
    required String device,
  }) =>
      _send(
        toUserId: customerId,
        fromUserId: technicianId,
        title: 'Request accepted',
        body: 'A technician accepted your $device repair.',
        requestId: requestId,
      );

  // 3 and 5. Status update / completed -> customer
  Future<void> statusChanged({
    required String customerId,
    required String technicianId,
    required String requestId,
    required String device,
    required String statusLabel,
    required bool completed,
  }) =>
      _send(
        toUserId: customerId,
        fromUserId: technicianId,
        title: completed ? 'Repair completed' : 'Status update',
        body: completed
            ? 'Your $device repair is complete.'
            : 'Your $device repair is now: $statusLabel.',
        requestId: requestId,
      );

  // 4. New chat message -> the other person
  Future<void> newMessage({
    required String toUserId,
    required String fromUserId,
    required String senderName,
    required String text,
    required String requestId,
  }) =>
      _send(
        toUserId: toUserId,
        fromUserId: fromUserId,
        title: 'New message from $senderName',
        body: text.length > 80 ? '${text.substring(0, 80)}...' : text,
        requestId: requestId,
      );
}
