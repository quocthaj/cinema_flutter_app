import 'package:flutter/material.dart';

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
