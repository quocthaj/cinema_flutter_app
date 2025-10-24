import 'package:flutter/material.dart';
import '../reward/reward_screen.dart';
import '../members/watched_movies_screen.dart';
import '../members/my_tickets_screen.dart';
import '../members/member_info_screen.dart';

// --- THÊM IMPORT CHO TRANG LOGIN ---
// (Hãy sửa lại đường dẫn này cho đúng với dự án của bạn)
import '../auth/login_screen.dart';

/// 🔹 BẢN MỚI — tương thích với HomeScreen
class ProfileDrawerDynamic extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;
  // --- THÊM BIẾN NÀY ---
  final bool isLoggedIn; // Dùng để kiểm tra trạng thái đăng nhập

  const ProfileDrawerDynamic({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
    // --- THÊM BIẾN NÀY VÀO CONSTRUCTOR ---
    required this.isLoggedIn,
  });

  // --- HÀM HELPER ĐỂ XỬ LÝ ĐIỀU HƯỚNG ---
  void _handleAuthNavigation(BuildContext context, Widget destinationScreen) {
    if (isLoggedIn) {
      // Đã đăng nhập -> đi đến màn hình
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destinationScreen),
      );
    } else {
      // Chưa đăng nhập -> đi đến LoginScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.95),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ... (Phần Header giữ nguyên) ...
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF9B3232),
                    const Color(0xFF9B3232).withOpacity(0.7),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundImage:
                              AssetImage("assets/images/avatar.png"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName, // Dùng tên được truyền vào
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Member badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              size: 16,
                              color: Colors.amber[300],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              userEmail.contains('Normal')
                                  ? 'Normal Member'
                                  : 'VIP Member',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        userEmail, // Dùng email được truyền vào
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Menu items
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.movie_rounded,
                    title: "Phim đã xem",
                    onTap: () {
                      Navigator.pop(context);
                      // --- SỬ DỤNG HÀM HELPER ---
                      _handleAuthNavigation(
                          context, const WatchedMoviesScreen());
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.confirmation_number_rounded,
                    title: "Vé của tôi",
                    onTap: () {
                      Navigator.pop(context);
                      // --- SỬ DỤNG HÀM HELPER ---
                      _handleAuthNavigation(context, const MyTicketsScreen());
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_rounded,
                    title: "Thông tin thành viên",
                    onTap: () {
                      Navigator.pop(context);
                      // --- SỬ DỤNG HÀM HELPER ---
                      _handleAuthNavigation(context, const MemberInfoScreen());
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.policy_rounded,
                    title: "Chính sách tích điểm",
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RewardScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 20),

                  // --- HIỂN THỊ NÚT ĐỘNG ---
                  if (isLoggedIn)
                    _buildLogoutButton(context, onLogout)
                  else
                    _buildLoginButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Hàm _buildMenuItem giữ nguyên) ...
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF9B3232).withOpacity(0.2),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: const Color(0xFF9B3232),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... (Hàm _buildDivider giữ nguyên) ...
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // --- NÚT ĐĂNG XUẤT (Lấy từ code gốc của bạn) ---
  Widget _buildLogoutButton(BuildContext context, VoidCallback onLogout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF9B3232).withOpacity(0.15),
        border: Border.all(
          color: const Color(0xFF9B3232).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onLogout, // Sử dụng callback được truyền vào
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF9B3232).withOpacity(0.3),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Color(0xFF9B3232),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    "Đăng xuất",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9B3232),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: const Color(0xFF9B3232).withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- NÚT ĐĂNG NHẬP (MỚI) ---
  Widget _buildLoginButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF9B3232).withOpacity(0.9), // Màu nổi bật
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context); // Đóng Drawer
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.login_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    "Đăng nhập",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
