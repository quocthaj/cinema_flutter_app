import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../config/theme.dart';

/// 🔐 Widget Guard để bảo vệ các màn hình admin
/// Chỉ cho phép admin truy cập, user thường sẽ thấy màn hình "Access Denied"
class AdminGuard extends StatelessWidget {
  final Widget child;
  final String screenName;

  const AdminGuard({
    super.key,
    required this.child,
    this.screenName = 'trang này',
  });

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();

    return FutureBuilder<bool>(
      future: adminService.isAdmin(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Kiểm tra quyền...'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Đang xác thực...',
                    style: TextStyle(color: AppTheme.textSecondaryColor),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if user is admin
        final isAdmin = snapshot.data ?? false;

        // Not admin - show access denied
        if (!isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('⛔ Truy cập bị từ chối'),
              backgroundColor: AppTheme.errorColor,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lock icon
                    Icon(
                      Icons.lock,
                      size: 100,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      'Bạn không có quyền truy cập',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Message
                    Text(
                      'Chỉ quản trị viên (admin) mới có thể truy cập $screenName.\n\n'
                      'Nếu bạn nghĩ đây là lỗi, vui lòng liên hệ với quản trị viên.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Back button
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Is admin - show the protected screen
        return child;
      },
    );
  }
}

/// 🔐 Admin Badge Widget - Hiển thị badge "ADMIN" trên AppBar
class AdminBadge extends StatelessWidget {
  const AdminBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.admin_panel_settings, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'ADMIN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
