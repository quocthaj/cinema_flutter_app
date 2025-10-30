import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_service.dart';
import '../../services/firestore_service.dart';
import '../../config/theme.dart';
import 'admin_guard.dart';
import 'seed_data_screen.dart';
import 'user_management_screen.dart';

/// 📊 Màn hình Admin Dashboard - Tổng quan hệ thống
/// 🔐 CHỈ ADMIN MỚI TRUY CẬP ĐƯỢC
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  final FirestoreService _firestoreService = FirestoreService();

  // Statistics data
  int _totalMovies = 0;
  int _totalTheaters = 0;
  int _totalScreens = 0;
  int _totalShowtimes = 0;
  int _totalBookings = 0;
  int _totalUsers = 0;
  int _totalAdmins = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  /// Load all statistics
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get movies and theaters (có stream method)
      final movies = await _firestoreService.getMoviesStream().first;
      final theaters = await _firestoreService.getTheatersStream().first;
      final adminStats = await _adminService.getAdminStats();

      // Count screens directly from Firestore
      final screensSnapshot = await FirebaseFirestore.instance
          .collection('screens')
          .get();
      
      // Count showtimes directly from Firestore
      final showtimesSnapshot = await FirebaseFirestore.instance
          .collection('showtimes')
          .get();
      
      // Count bookings directly from Firestore
      final bookingsSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .get();

      setState(() {
        _totalMovies = movies.length;
        _totalTheaters = theaters.length;
        _totalScreens = screensSnapshot.docs.length;
        _totalShowtimes = showtimesSnapshot.docs.length;
        _totalBookings = bookingsSnapshot.docs.length;
        _totalUsers = adminStats['totalUsers'] ?? 0;
        _totalAdmins = adminStats['totalAdmins'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      screenName: 'Admin Dashboard',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📊 Admin Dashboard'),
          actions: const [
            AdminBadge(),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadStatistics,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome card
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),

                      // Statistics grid
                      Text(
                        '📈 Thống kê hệ thống',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildStatisticsGrid(),
                      const SizedBox(height: 24),

                      // Quick actions
                      Text(
                        '⚡ Thao tác nhanh',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                      const SizedBox(height: 40), // Extra bottom padding
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chào mừng Admin!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quản lý toàn bộ hệ thống TNT Cinema',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1, // Giảm thêm từ 1.3 → 1.2
      children: [
        _buildStatCard(
          icon: Icons.movie,
          label: 'Phim',
          value: _totalMovies.toString(),
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.theaters,
          label: 'Rạp chiếu',
          value: _totalTheaters.toString(),
          color: Colors.purple,
        ),
        _buildStatCard(
          icon: Icons.meeting_room,
          label: 'Phòng chiếu',
          value: _totalScreens.toString(),
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.schedule,
          label: 'Suất chiếu',
          value: _totalShowtimes.toString(),
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.confirmation_number,
          label: 'Đặt vé',
          value: _totalBookings.toString(),
          color: Colors.amber,
        ),
        _buildStatCard(
          icon: Icons.people,
          label: 'Người dùng',
          value: _totalUsers.toString(),
          color: Colors.teal,
        ),
        _buildStatCard(
          icon: Icons.admin_panel_settings,
          label: 'Quản trị viên',
          value: _totalAdmins.toString(),
          color: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.settings_input_component,
          title: 'Quản lý dữ liệu',
          subtitle: 'Seed, xóa, backup dữ liệu',
          color: Colors.deepPurple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SeedDataScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.people,
          title: 'Quản lý người dùng',
          subtitle: 'Xem, promote, demote users',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserManagementScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.refresh,
          title: 'Làm mới dữ liệu',
          subtitle: 'Reload statistics',
          color: Colors.green,
          onTap: _loadStatistics,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
