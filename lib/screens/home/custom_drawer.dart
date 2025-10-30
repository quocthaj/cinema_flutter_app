import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/seed_data_screen.dart';
import '../admin/user_management_screen.dart';
import '../reward/reward_screen.dart';
import '../news/news_and_promotions_screen.dart';
import 'contact/contact_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService adminService = AdminService();

    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.95),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header với gradient và blur effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF9B3232),
                    const Color(0xFF9B3232).withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo/Icon với shadow
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.movie_creation_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "TNT CINEMA",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Premium Experience",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Menu items với iOS style
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.confirmation_number_rounded,
                    title: "Mua vé",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.local_movies_rounded,
                    title: "Phim",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.theaters_rounded,
                    title: "Rạp",
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),
                  _buildDivider(),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    context,
                    icon: Icons.local_offer_rounded,
                    title: "Khuyến mãi",
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewsAndPromotionsPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.card_giftcard_rounded,
                    title: "Quà tặng",
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RewardScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.contact_mail_rounded,
                    title: "Liên hệ",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactScreen(),
                        ),
                      );
                    },
                  ),

                  // 🔥 ADMIN SECTION - Chỉ hiện khi user là admin
                  StreamBuilder<bool>(
                    stream: adminService.isAdminStream(),
                    builder: (context, snapshot) {
                      final isAdmin = snapshot.data ?? false;
                      
                      if (!isAdmin) {
                        return const SizedBox.shrink(); // Ẩn hoàn toàn nếu không phải admin
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildDivider(),
                          const SizedBox(height: 15),
                          
                          // Header "QUẢN TRỊ"
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  size: 18,
                                  color: const Color(0xFF9B3232),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "QUẢN TRỊ",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF9B3232),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Admin menu items
                          _buildMenuItem(
                            context,
                            icon: Icons.dashboard_rounded,
                            title: "Admin Dashboard",
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminDashboardScreen(),
                                ),
                              );
                            },
                            isAdmin: true,
                          ),
                          _buildMenuItem(
                            context,
                            icon: Icons.settings_input_component,
                            title: "Quản lý dữ liệu",
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SeedDataScreen(),
                                ),
                              );
                            },
                            isAdmin: true,
                          ),
                          _buildMenuItem(
                            context,
                            icon: Icons.people_rounded,
                            title: "Quản lý người dùng",
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UserManagementScreen(),
                                ),
                              );
                            },
                            isAdmin: true,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isAdmin = false, // Flag để style admin items khác biệt
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isAdmin 
            ? const Color(0xFF9B3232).withOpacity(0.15) // Admin items có background đỏ nhạt
            : Colors.white.withOpacity(0.05),
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
                    color: const Color(0xFF9B3232).withOpacity(isAdmin ? 0.3 : 0.2),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isAdmin ? const Color(0xFF9B3232) : const Color(0xFF9B3232),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isAdmin ? FontWeight.w600 : FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B3232),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
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
}
