import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/theater_model.dart';
import '../../services/firestore_service.dart';
import 'theater_detail_screen.dart';
import '../home/bottom_nav_bar.dart';
import '../movie/movie_screen.dart';
import '../reward/reward_screen.dart';
import '../home/home_screen.dart';
import '../news/news_and_promotions_screen.dart';

class TheatersScreen extends StatefulWidget {
  const TheatersScreen({super.key});

  @override
  State<TheatersScreen> createState() => _TheatersScreenState();
}

class _TheatersScreenState extends State<TheatersScreen> {
  int _currentIndex = 3; // ✅ "Rạp" là tab thứ 4 trong thanh điều hướng
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🎥 Danh sách rạp chiếu",
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Theater>>(
        stream: _firestoreService.getTheatersStream(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text('Lỗi khi tải dữ liệu', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), style: TextStyle(color: AppTheme.textSecondaryColor)),
                ],
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.theaters_outlined, size: 60, color: AppTheme.textSecondaryColor),
                  const SizedBox(height: 16),
                  Text('Chưa có rạp nào', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Vui lòng seed data từ Admin panel', style: TextStyle(color: AppTheme.textSecondaryColor)),
                ],
              ),
            );
          }

          // Success - Display theaters
          final theaters = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: theaters.length,
            itemBuilder: (context, index) {
              final theater = theaters[index];
              return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                child: Icon(Icons.theaters, color: AppTheme.primaryColor),
                radius: 28,
                backgroundColor: AppTheme.fieldColor,
              ),
              title: Text(
                theater.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                theater.address,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: AppTheme.textSecondaryColor, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TheaterDetailScreen(theater: theater),
                  ),
                );
              },
            ),
          );
        },
      );
        },
      ),

      // ✅ Thêm thanh điều hướng dưới cùng
      bottomNavigationBar: BottomNavBar(
        initialIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MovieScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RewardScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 3) {
            // Ở trang hiện tại (Rạp)
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NewsAndPromotionsPage()),
            );
          }
        },
      ),
    );
  }
}
