import 'package:flutter/material.dart';

/// 🔹 BẢN GỐC (giữ nguyên)
class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black87),
            accountName: const Text("Quốc Thái"),
            accountEmail: const Text("Normal - C.COIN 26.000"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage("assets/images/avatar.png"),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.movie, color: Colors.white),
            title: const Text("Phim đã xem", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.confirmation_number, color: Colors.white),
            title: const Text("Vé của tôi", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text("Thông tin thành viên", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.policy, color: Colors.white),
            title: const Text("Chính sách tích điểm", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// 🔹 BẢN MỚI — tương thích với HomeScreen
class ProfileDrawerDynamic extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const ProfileDrawerDynamic({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black87),
            accountName: Text(userName, style: const TextStyle(color: Colors.white)),
            accountEmail: Text(userEmail, style: const TextStyle(color: Colors.white70)),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage("assets/images/avatar.png"),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.movie, color: Colors.white),
            title: const Text("Phim đã xem", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.confirmation_number, color: Colors.white),
            title: const Text("Vé của tôi", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text("Thông tin thành viên", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.policy, color: Colors.white),
            title: const Text("Chính sách tích điểm", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Đăng xuất", style: TextStyle(color: Colors.redAccent)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
