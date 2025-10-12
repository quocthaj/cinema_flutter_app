// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../widgets/colors.dart';

class BottomNavBar extends StatelessWidget {
  final Function(int) onTap;
  final int initialIndex;

  const BottomNavBar({
    super.key,
    required this.onTap,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      backgroundColor: ColorbuttonColor, // màu nút chính
      style: TabStyle.titled, // có tiêu đề dưới icon
      items: const [
        TabItem(icon: Icons.home, title: 'Trang chủ'), // ✅ thêm trang chủ
        TabItem(icon: Icons.movie, title: 'Phim'),
        TabItem(icon: Icons.card_giftcard, title: 'Quà tặng'),
        TabItem(icon: Icons.theaters, title: 'Rạp'),
        TabItem(icon: Icons.local_offer, title: 'Khuyến mãi'),
      ],
      initialActiveIndex: initialIndex,
      onTap: onTap,
    );
  }
}
