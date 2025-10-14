import 'package:flutter/material.dart';
import '../widgets/colors.dart';
import '../home/bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../movie/movie_screen.dart';
import '../theater/theaters_screen.dart';
import 'reward_details.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  int _currentIndex = 1; // Mặc định tab "Quà tặng"
  
  final List<Map<String, dynamic>> _rewards = [
    {'title': '1 Vé xem phim miễn phí', 'points': 500, 'image': 'lib/images/free_ticket.jpg'},
    {'title': 'Combo bắp + nước', 'points': 300, 'image': 'lib/images/popcorn_combo.jpg'},
    {'title': 'Voucher giảm 50%', 'points': 700, 'image': 'lib/images/discount_voucher.jpg'},
  ];

  final List<Map<String, dynamic>> _tickets = [
    {'title': 'Vé xem phim 2D', 'price': 130000, 'duration': '12 tháng', 'image': 'lib/images/free_ticket.jpg'},
    {'title': 'Vé SUPER PLEX', 'price': 150000, 'duration': '12 tháng', 'image': 'lib/images/superplex_ticket.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: ColorbuttonColor,
        title: const Text(
          '🎁 Chính sách tích điểm & Quà tặng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Cách tích điểm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Mỗi 10.000đ chi tiêu = 1 điểm.\n'
              '• Điểm được tích tự động khi đặt vé hoặc mua combo.\n'
              '• Điểm có thể dùng để đổi quà trong mục bên dưới.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              '🏅 Cấp độ thành viên',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            _buildMembershipLevels(),
            const SizedBox(height: 20),
            const Text(
              '🎁 Quà tặng có thể đổi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            _buildRewardList(),
            const SizedBox(height: 30),
            const Text(
              '🎟️ Mua vé xem phim',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            _buildTicketList(),
          ],
        ),
      ),

      // ✅ Thêm điều hướng thống nhất
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
            // Trang hiện tại (Quà tặng)
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("🎫 Tính năng khuyến mãi đang phát triển!")),
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
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.star, color: Colors.amber),
            title: Text('Silver', style: TextStyle(color: Colors.white)),
            subtitle: Text('Từ 0 - 499 điểm', style: TextStyle(color: Colors.white54)),
          ),
          ListTile(
            leading: Icon(Icons.star_half, color: Colors.blueAccent),
            title: Text('Gold', style: TextStyle(color: Colors.white)),
            subtitle: Text('Từ 500 - 999 điểm', style: TextStyle(color: Colors.white54)),
          ),
          ListTile(
            leading: Icon(Icons.star_rate, color: Colors.redAccent),
            title: Text('Diamond', style: TextStyle(color: Colors.white)),
            subtitle: Text('Từ 1000 điểm trở lên', style: TextStyle(color: Colors.white54)),
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
          color: Colors.grey.shade800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(reward['image'], width: 50, height: 50, fit: BoxFit.cover),
            ),
            title: Text(reward['title'], style: const TextStyle(color: Colors.white)),
            subtitle: Text('${reward['points']} điểm', style: const TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(
              onPressed: () => _showExchangeDialog(reward['title'], reward['points']),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
          color: Colors.grey.shade800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(ticket['image'], width: 70, height: 50, fit: BoxFit.cover),
            ),
            title: Text(ticket['title'],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Hạn sử dụng: ${ticket['duration']}',
                style: const TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RewardDetailsPage(ticket: ticket)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('${ticket['price']} đ', style: const TextStyle(color: Colors.white)),
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
        backgroundColor: const Color(0xFF2C2C2E),
        title: Text('Đổi quà: $rewardName', style: const TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có muốn dùng $points điểm để đổi phần quà này không?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
