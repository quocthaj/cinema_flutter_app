import 'package:flutter/material.dart';
import '../../config/theme.dart';
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

  final List<Map<String, dynamic>> _promotions = [
    {
      'title': 'TẶNG HOA XIN - MỪNG 20/10 RẠNG RỠ!',
      'image': 'lib/images/promo_flower.jpg',
      'date': '20/10/2025 - 21/10/2025',
      'content': '''
- Mừng ngày Phụ nữ Việt Nam, TNT CINEMA tặng ngay HOA XINH cho các nàng khi: Mua 2 VÉ XEM PHIM kèm COMBO BẮP NƯỚC BẤT KỲ (Áp dụng tại tất cả cụm rạp, số lượng có hạn).

- 20/10 cũng là ngày Big Smile Day, vé xem phim chỉ từ 45K, combo 1 bắp 2 nước chỉ 87K.

Lưu ý:
1. Vé có thể đặt online hoặc mua trực tiếp tại quầy.
2. Riêng combo bắp nước ưu đãi vui lòng mua trực tiếp tại quầy.
'''
    },
    {
      'title': 'BẮT BÓNG RINH QUÀ CÙNG TNT CINEMA!',
      'image': 'lib/images/promo_ball.jpg',
      'date': '19/10/2025 - 20/10/2025',
      'content': '''
Thể lệ: Mua vé phim kèm combo bắp nước bất kỳ, nhận 1 lượt chơi bắt bóng trúng quà ngẫu nhiên tại khu vực mini game.

Áp dụng: TNT CINE GÒ VẤP, NAM SÀI GÒN, WEST LAKE.
'''
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TIN MỚI & ƯU ĐÃI'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _promotions.length,
        itemBuilder: (context, index) {
          final promo = _promotions[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => NewsDetailsPage(promotion: promo)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(promo['image'], fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo['title'],
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_month,
                                size: 16, color: AppTheme.textSecondaryColor),
                            const SizedBox(width: 6),
                            Text(
                              promo['date'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
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
