import 'package:flutter/material.dart';
import 'dart:ui';
import '../../data/mock_Data.dart';
import '../../models/movie.dart';
import '../movie_detail/movie_detail_screen.dart'; // 👈 Thêm dòng này để điều hướng
import '../widgets/colors.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  void _handleBooking(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Chức năng đặt vé đang phát triển...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color semiTransparentColor = datve.withOpacity(0.7);
    const double blurSigma = 5.0;

    return GestureDetector(
      onTap: () {
        // 👇 Khi nhấn vào card => đi đến trang chi tiết phim
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ảnh phim
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Hero(
                tag: movie.id, // 👈 để tạo hiệu ứng Hero khi chuyển trang
                child: Image.asset(
                  movie.posterUrl,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        "${movie.rating}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      Text(
                        "${movie.duration} Phút",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                        child: GestureDetector(
                          onTap: () => _handleBooking(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: semiTransparentColor,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Đặt vé",
                              style: TextStyle(
                                fontSize: 14,
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
          ],
        ),
      ),
    );
  }
}
