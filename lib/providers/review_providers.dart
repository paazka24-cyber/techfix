import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import '../repositories/review_repository.dart';
import 'auth_providers.dart';

final reviewRepositoryProvider =
    Provider<ReviewRepository>((ref) => ReviewRepository());

final requestReviewProvider =
    StreamProvider.family<Review?, String>((ref, requestId) {
  return ref.watch(reviewRepositoryProvider).watchForRequest(requestId);
});

final technicianReviewsProvider =
    StreamProvider.family<List<Review>, String>((ref, technicianId) {
  return ref.watch(reviewRepositoryProvider).watchForTechnician(technicianId);
});

// Reviews of the logged-in technician
final myReviewsProvider = StreamProvider<List<Review>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(reviewRepositoryProvider).watchForTechnician(user.uid);
});
