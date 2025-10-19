import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../home/bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../movie/movie_screen.dart';
import '../theater/theaters_screen.dart';
import '../news/news_and_promotions_screen.dart';
import 'reward_details.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  int _currentIndex = 1; // Mặc định tab "Quà tặng"

  final List<Map<String, dynamic>> _rewards = [
    {
      'title': '1 Vé xem phim miễn phí',
      'points': 500,
      'image': 'lib/images/free_ticket.jpg'
    },
    {
      'title': 'Combo bắp + nước',
      'points': 300,
      'image': 'lib/images/popcorn_combo.jpg'
    },
    {
      'title': 'Voucher giảm 50%',
      'points': 700,
      'image': 'lib/images/discount_voucher.jpg'
    },
  ];

  final List<Map<String, dynamic>> _tickets = [
    {
      'title': 'Vé xem phim 2D',
      'price': 130000,
      'duration': '12 tháng',
      'image': 'lib/images/free_ticket.jpg'
    },
    {
      'title': 'Vé SUPER PLEX',
      'price': 150000,
      'duration': '12 tháng',
      'image': 'lib/images/superplex_ticket.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎁 Chính sách tích điểm & Quà tặng',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Cách tích điểm',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '• Mỗi 10.000đ chi tiêu = 1 điểm.\n'
              '• Điểm được tích tự động khi đặt vé hoặc mua combo.\n'
              '• Điểm có thể dùng để đổi quà trong mục bên dưới.',
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            Text(
              '🏅 Cấp độ thành viên',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildMembershipLevels(),
            const SizedBox(height: 20),
            Text(
              '🎁 Quà tặng có thể đổi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildRewardList(),
            const SizedBox(height: 30),
            Text(
              '🎟️ Mua vé xem phim',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildTicketList(),
          ],
        ),
      ),

      // ✅ Thanh điều hướng dưới
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
            // Trang hiện tại: Quà tặng
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TheatersScreen()),
            );
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

  // ====== Widget cấp độ thành viên ======
  Widget _buildMembershipLevels() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.star, color: AppTheme.goldColor),
            title: Text('Silver', style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text('Từ 0 - 499 điểm',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          ListTile(
            leading: const Icon(Icons.star_half, color: Colors.blueAccent),
            title: Text('Gold', style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text('Từ 500 - 999 điểm',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          ListTile(
            leading: Icon(Icons.star_rate, color: AppTheme.primaryColor),
            title:
                Text('Diamond', style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text('Từ 1000 điểm trở lên',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  // ====== Danh sách quà tặng ======
  Widget _buildRewardList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _rewards.length,
      itemBuilder: (context, index) {
        final reward = _rewards[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(reward['image'],
                  width: 50, height: 50, fit: BoxFit.cover),
            ),
            title: Text(reward['title']),
            subtitle: Text('${reward['points']} điểm',
                style: Theme.of(context).textTheme.bodyMedium),
            trailing: ElevatedButton(
              onPressed: () =>
                  _showExchangeDialog(reward['title'], reward['points']),
              child: const Text('Đổi quà'),
            ),
          ),
        );
      },
    );
  }

  // ====== Danh sách vé ======
  Widget _buildTicketList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(ticket['image'],
                  width: 70, height: 50, fit: BoxFit.cover),
            ),
            title: Text(ticket['title'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Hạn sử dụng: ${ticket['duration']}',
                style: Theme.of(context).textTheme.bodyMedium),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RewardDetailsPage(ticket: ticket)),
                );
              },
              child: Text('${ticket['price']} đ'),
            ),
          ),
        );
      },
    );
  }

  // ====== Hộp thoại đổi quà ======
  void _showExchangeDialog(String rewardName, int points) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text('Đổi quà: $rewardName',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          'Bạn có muốn dùng $points điểm để đổi phần quà này không?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy',
                style: TextStyle(color: AppTheme.textSecondaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Bạn đã đổi thành công "$rewardName"!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
