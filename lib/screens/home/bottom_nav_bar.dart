// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../widgets/colors.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onTap;
  final int initialIndex;

  const BottomNavBar({
    super.key,
    required this.onTap,
    this.initialIndex = 2, // ✅ Mặc định chọn "Trang chủ"
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      backgroundColor: ColorbuttonColor,
      style: TabStyle.titled,
      items: const [
        TabItem(icon: Icons.movie, title: 'Phim'),
        TabItem(icon: Icons.card_giftcard, title: 'Quà tặng'),
        TabItem(icon: Icons.home, title: 'Trang chủ'),
        TabItem(icon: Icons.theaters, title: 'Rạp'),
        TabItem(icon: Icons.local_offer, title: 'Khuyến mãi'),
      ],
      initialActiveIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        widget.onTap(index);
      },
    );
  }
}