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
      backgroundColor: ColorbuttonColor ,
      style: TabStyle.react, // hiệu ứng đẹp hơn
      items: const [
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
