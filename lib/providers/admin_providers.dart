import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../models/repair_request.dart';
import '../repositories/admin_repository.dart';

final adminRepositoryProvider =
    Provider<AdminRepository>((ref) => AdminRepository());

final allUsersProvider = StreamProvider<List<AppUser>>(
    (ref) => ref.watch(adminRepositoryProvider).watchAllUsers());

final allRequestsProvider = StreamProvider<List<RepairRequest>>(
    (ref) => ref.watch(adminRepositoryProvider).watchAllRequests());
