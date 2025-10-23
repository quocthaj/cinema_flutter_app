import 'package:flutter/material.dart';
import 'dart:ui';
import '../../config/theme.dart';
import '../../models/movie.dart';
import '../movie/movie_detail_screen.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double? width; // 👈 ĐÃ THÊM: Tham số chiều rộng (tùy chọn)
  final double? height; // 👈 ĐÃ THÊM: Tham số chiều cao (tùy chọn)

  // Cập nhật constructor để nhận các tham số width và height
  const MovieCard({
    super.key,
    required this.movie,
    this.width,
    this.height,
  });

  void _handleBooking(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Chức năng đặt vé đang phát triển...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = width ?? 220.0;
    final double cardHeight = height ?? 340.0;
    final Color semiTransparentColor = AppTheme.primaryColor.withOpacity(0.7);
    const double blurSigma = 5.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ảnh phim - chiếm 65% chiều cao card
            Expanded(
              flex: 65,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Hero(
                  tag: movie.id,
                  child: Image.network(
                    movie.posterUrl,
                    width: cardWidth,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppTheme.cardColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.cardColor,
                        child: const Center(
                          child: Icon(
                            Icons.movie_creation_outlined,
                            color: Colors.white54,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Phần thông tin - chiếm 35% chiều cao card
            Expanded(
              flex: 35,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tên phim
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Rating & Duration
                    Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.goldColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "${movie.rating}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time,
                            size: 14, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          "${movie.duration}'",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    // Nút Đặt vé
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: blurSigma, sigmaY: blurSigma),
                          child: GestureDetector(
                            onTap: () => _handleBooking(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: semiTransparentColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Đặt vé",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
