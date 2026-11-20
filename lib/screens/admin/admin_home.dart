import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import 'admin_categories_tab.dart';
import 'admin_overview_tab.dart';
import 'admin_requests_tab.dart';
import 'admin_users_tab.dart';

class AdminHome extends ConsumerWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authRepositoryProvider).logout(),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Users'),
              Tab(text: 'Requests'),
              Tab(text: 'Categories'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminOverviewTab(),
            AdminUsersTab(),
            AdminRequestsTab(),
            AdminCategoriesTab(),
          ],
        ),
      ),
    );
  }
}
