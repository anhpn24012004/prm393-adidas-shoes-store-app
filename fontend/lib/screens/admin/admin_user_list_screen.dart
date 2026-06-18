import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../models/admin_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final _service = AdminService();
  final _searchController = TextEditingController();
  late Future<List<AdminUserSummary>> _future;
  bool? _isActive;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    _future = _service.getUsers(
      keyword: _searchController.text.trim(),
      isActive: _isActive,
    );
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  Future<void> _toggleUser(AdminUserSummary user, bool isActive) async {
    try {
      await _service.updateUserStatus(user.userId, isActive);
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return context.tr('notAvailable');
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _roleLabel(String role) {
    return role == 'Admin'
        ? context.tr('adminRole')
        : context.tr('customerRole');
  }

  String _initials(AdminUserSummary user) {
    final source = user.fullName.trim().isEmpty
        ? user.email.trim()
        : user.fullName.trim();
    if (source.isEmpty) return '?';

    return source
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
  }

  Widget _buildFilterChip(String label, bool? value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _isActive == value,
        onSelected: (_) {
          setState(() {
            _isActive = value;
            _reload();
          });
        },
      ),
    );
  }

  Widget _buildUserCard(AdminUserSummary user) {
    final initials = _initials(user);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: user.isActive ? AppColors.black : Colors.grey,
              foregroundColor: Colors.white,
              child: Text(initials),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName.isEmpty ? user.email : user.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_roleLabel(user.roleName)} - ${user.isActive ? context.tr('active') : context.tr('inactive')}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${context.tr('createdAt')}: ${_formatDate(user.createdAt)}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoPill(
                        text:
                            '${context.tr('metricOrders')}: ${user.orderCount}',
                      ),
                      _InfoPill(
                        text:
                            '${context.tr('metricReturns')}: ${user.returnRequestCount}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: user.isActive,
              onChanged: (value) => _toggleUser(user, value),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('userManagement'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => setState(_reload),
              decoration: InputDecoration(
                hintText: context.tr('userSearchHint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () => setState(_reload),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(context.tr('all'), null),
                _buildFilterChip(context.tr('active'), true),
                _buildFilterChip(context.tr('inactive'), false),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AdminUserSummary>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${context.tr('error')}: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                      ),
                    ),
                  );
                }

                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return Center(child: Text(context.tr('noUsersFound')));
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: users.length,
                    itemBuilder: (context, index) =>
                        _buildUserCard(users[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;

  const _InfoPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
