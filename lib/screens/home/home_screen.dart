import 'package:flutter/material.dart';
import '../../data/mock_Data.dart';
import '../widgets/movie_card.dart';
import 'bottom_nav_bar.dart'; // import đúng từ widgets
import 'custom_drawer.dart';
import 'profile_drawer.dart';
import '../widgets/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(), // 👉 Drawer bên trái
      endDrawer: const ProfileDrawer(), // 👉 Drawer bên phải cho user
      appBar: AppBar(
        backgroundColor: ColorbuttonColor,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.person), // 👉 icon người dùng
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // 👉 mở ProfileDrawer
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 👉 căn giữa dọc màn hình
          crossAxisAlignment: CrossAxisAlignment.center, // 👉 căn giữa ngang
          children: [
            const Text(
              "Đang chiếu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 500,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mockMovies.length,
                itemBuilder: (context, index) {
                  final movie = mockMovies[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: MovieCard(movie: movie),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // 👉 chỉ giữ lại bottom nav bar này
      bottomNavigationBar: BottomNavBar(
        initialIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
