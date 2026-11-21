import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/theme_toggle_button.dart';
import 'admin_categories_tab.dart';
import 'admin_overview_tab.dart';
import 'admin_requests_tab.dart';
import 'admin_users_tab.dart';

class AdminHome extends ConsumerStatefulWidget {
  const AdminHome({super.key});

  @override
  ConsumerState<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends ConsumerState<AdminHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);
  final _userFilter = ValueNotifier<String>('all');
  final _requestFilter = ValueNotifier<String>('all');

  @override
  void dispose() {
    _tabs.dispose();
    _userFilter.dispose();
    _requestFilter.dispose();
    super.dispose();
  }

  void _openUsers(String filter) {
    _userFilter.value = filter;
    _tabs.animateTo(1);
  }

  void _openRequests(String filter) {
    _requestFilter.value = filter;
    _tabs.animateTo(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).logout(),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Users'),
            Tab(text: 'Requests'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          AdminOverviewTab(
            onOpenUsers: _openUsers,
            onOpenRequests: _openRequests,
          ),
          AdminUsersTab(filter: _userFilter),
          AdminRequestsTab(filter: _requestFilter),
          const AdminCategoriesTab(),
        ],
      ),
    );
  }
}
