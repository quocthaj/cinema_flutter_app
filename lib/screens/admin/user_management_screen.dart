import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/user_model.dart';
import '../../config/theme.dart';
import 'admin_guard.dart';

/// 👥 Màn hình quản lý users
/// 🔐 CHỈ ADMIN MỚI TRUY CẬP ĐƯỢC
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Promote user lên admin
  Future<void> _promoteUser(String userId, String userName) async {
    final confirm = await _showConfirmDialog(
      title: 'Promote lên Admin',
      message: 'Bạn có chắc muốn promote "$userName" lên admin?',
      confirmText: 'Promote',
      isDestructive: false,
    );

    if (confirm != true) return;

    try {
      await _adminService.promoteToAdmin(userId);
      if (mounted) {
        _showSuccessSnackBar('✅ Đã promote "$userName" lên admin');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ Lỗi: $e');
      }
    }
  }

  /// Demote admin xuống user
  Future<void> _demoteUser(String userId, String userName) async {
    final confirm = await _showConfirmDialog(
      title: 'Demote xuống User',
      message: 'Bạn có chắc muốn demote "$userName" xuống user thường?',
      confirmText: 'Demote',
      isDestructive: true,
    );

    if (confirm != true) return;

    try {
      await _adminService.demoteToUser(userId);
      if (mounted) {
        _showSuccessSnackBar('✅ Đã demote "$userName" xuống user');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ Lỗi: $e');
      }
    }
  }

  /// Xóa user
  Future<void> _deleteUser(String userId, String userName) async {
    final confirm = await _showConfirmDialog(
      title: '⚠️ Xóa User',
      message: 'Bạn có chắc muốn XÓA user "$userName"?\n\n'
          'Hành động này không thể hoàn tác!',
      confirmText: 'Xóa',
      isDestructive: true,
    );

    if (confirm != true) return;

    try {
      await _adminService.deleteUser(userId);
      if (mounted) {
        _showSuccessSnackBar('✅ Đã xóa user "$userName"');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ Lỗi: $e');
      }
    }
  }

  /// Show confirm dialog
  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? Colors.red : AppTheme.primaryColor,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      screenName: 'Quản lý người dùng',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('👥 Quản lý người dùng'),
          actions: const [
            AdminBadge(),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên hoặc email...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Statistics card
            FutureBuilder<Map<String, int>>(
              future: _adminService.getAdminStats(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {};
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.people,
                          label: 'Tổng users',
                          value: stats['totalUsers']?.toString() ?? '0',
                          color: Colors.blue,
                        ),
                        _buildStatItem(
                          icon: Icons.admin_panel_settings,
                          label: 'Admins',
                          value: stats['totalAdmins']?.toString() ?? '0',
                          color: AppTheme.primaryColor,
                        ),
                        _buildStatItem(
                          icon: Icons.person,
                          label: 'Users thường',
                          value: stats['regularUsers']?.toString() ?? '0',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // User list
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _adminService.getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Lỗi: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Chưa có user nào'),
                    );
                  }

                  // Filter users based on search
                  var users = snapshot.data!;
                  if (_searchQuery.isNotEmpty) {
                    users = users.where((user) {
                      final name = user.name.toLowerCase();
                      final email = user.email.toLowerCase();
                      return name.contains(_searchQuery) || email.contains(_searchQuery);
                    }).toList();
                  }

                  if (users.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy user nào'),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserCard(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    final isAdmin = user.isAdmin;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAdmin ? AppTheme.primaryColor : Colors.grey,
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Text(
              'Tham gia: ${_formatDate(user.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'promote':
                _promoteUser(user.id, user.name);
                break;
              case 'demote':
                _demoteUser(user.id, user.name);
                break;
              case 'delete':
                _deleteUser(user.id, user.name);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!isAdmin)
              const PopupMenuItem(
                value: 'promote',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Promote lên Admin'),
                  ],
                ),
              ),
            if (isAdmin)
              const PopupMenuItem(
                value: 'demote',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Demote xuống User'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa user'),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
