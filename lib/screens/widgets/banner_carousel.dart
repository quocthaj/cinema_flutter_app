import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import '../../config/theme.dart';

/// Widget riêng cho banner carousel
/// Tách ra để setState chỉ rebuild banner, không rebuild toàn bộ HomeScreen
class BannerCarousel extends StatefulWidget {
  final List<String> banners;

  const BannerCarousel({
    super.key,
    required this.banners,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentBanner = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            height: 200,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, _) {
              setState(() => _currentBanner = index);
            },
          ),
          items: widget.banners.map((img) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                img,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.banners.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentBanner == entry.key ? 10 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 3,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBanner == entry.key
                    ? AppTheme.primaryColor
                    : Colors.white38,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
