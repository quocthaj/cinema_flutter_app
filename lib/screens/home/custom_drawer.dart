import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            child: Center(
              child: Text(
                "LOTTE CINEMA",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.movie),
            title: const Text("Mua vé"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.local_movies),
            title: const Text("Phim"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.theaters),
            title: const Text("Rạp"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.discount),
            title: const Text("Khuyến mãi"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text("Quà tặng"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text("Liên hệ"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
