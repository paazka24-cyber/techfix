import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../models/device_category.dart';
import '../models/repair_request.dart';
import '../repositories/category_repository.dart';
import '../repositories/repair_repository.dart';
import '../repositories/user_repository.dart';
import 'auth_providers.dart';

final repairRepositoryProvider =
    Provider<RepairRepository>((ref) => RepairRepository());

final categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) => CategoryRepository());

final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository());

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

final availableRequestsProvider = StreamProvider<List<RepairRequest>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(repairRepositoryProvider).watchAvailableRequests(user.uid);
});

final technicianJobsProvider = StreamProvider<List<RepairRequest>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(repairRepositoryProvider).watchTechnicianJobs(user.uid);
});

final requestProvider =
    StreamProvider.family<RepairRequest?, String>((ref, id) {
  return ref.watch(repairRepositoryProvider).watchRequest(id);
});

final techniciansProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).watchTechnicians();
});
