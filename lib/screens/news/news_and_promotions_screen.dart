import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/news_model.dart';
import '../movie/movie_screen.dart';
import '../theater/theaters_screen.dart';
import '../home/bottom_nav_bar.dart';
import '../home/home_screen.dart';
import 'news_details.dart';
import '../reward/reward_screen.dart';

class NewsAndPromotionsPage extends StatefulWidget {
  const NewsAndPromotionsPage({super.key});

  @override
  State<NewsAndPromotionsPage> createState() => _NewsAndPromotionsPageState();
}

class _NewsAndPromotionsPageState extends State<NewsAndPromotionsPage> {
  int _currentIndex = 4; // Mặc định chọn tab "Khuyến mãi"
  final _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TIN MỚI & ƯU ĐÃI'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<NewsModel>>(
        stream: _firestore.getNewsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text('Hiện chưa có tin tức.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final news = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NewsDetailsPage(news: news)),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image (network or asset)
                      news.imageUrl.startsWith('http')
                          ? Image.network(news.imageUrl, fit: BoxFit.cover)
                          : Image.asset(news.imageUrl, fit: BoxFit.cover),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_month, size: 16, color: AppTheme.textSecondaryColor),
                                const SizedBox(width: 6),
                                Text(news.dateRange, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        initialIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            // Mở trang Phim
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MovieScreen()),
            );
          }
          if (index == 1) {
            // Mở trang Reward
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RewardScreen()),
            );
          }
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TheatersScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}
