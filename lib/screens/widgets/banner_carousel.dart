import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import '../../config/theme.dart';
import '../../models/news_model.dart';
import '../news/news_details.dart';

/// Widget riêng cho banner carousel
/// Tách ra để setState chỉ rebuild banner, không rebuild toàn bộ HomeScreen
class BannerCarousel extends StatefulWidget {
  final List<NewsModel>? newsItems;

  const BannerCarousel({
    super.key,
    this.newsItems,
  }) : assert(newsItems != null, 'newsItems must be provided');

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentBanner = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.newsItems == null || widget.newsItems!.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Chưa có tin tức',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

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
          items: widget.newsItems!.map((news) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsDetailsPage(news: news),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: news.imageUrl.startsWith('http')
                      ? Image.network(
                          news.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.cardColor,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          news.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.cardColor,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            );
          }).toList(),
        ),
        // Dots indicator
        Positioned(
          bottom: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.newsItems!.length,
              (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentBanner == index ? 10 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBanner == index
                        ? AppTheme.primaryColor
                        : Colors.white38,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
