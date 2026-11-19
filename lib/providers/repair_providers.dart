import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_category.dart';
import '../models/repair_request.dart';
import '../repositories/category_repository.dart';
import '../repositories/repair_repository.dart';
import 'auth_providers.dart';

final repairRepositoryProvider =
    Provider<RepairRepository>((ref) => RepairRepository());

final categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) => CategoryRepository());

final categoriesProvider = StreamProvider<List<DeviceCategory>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  repo.seedDefaultsIfEmpty();
  return repo.watchCategories();
});

final myRequestsProvider = StreamProvider<List<RepairRequest>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(repairRepositoryProvider).watchCustomerRequests(user.uid);
});

final requestProvider =
    StreamProvider.family<RepairRequest?, String>((ref, id) {
  return ref.watch(repairRepositoryProvider).watchRequest(id);
});
