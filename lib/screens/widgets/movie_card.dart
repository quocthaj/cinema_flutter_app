import 'package:flutter/material.dart';
import 'dart:ui';
import '../../data/mock_Data.dart';
import '../../models/movie.dart';
import '../movie/movie_detail_screen.dart'; 
import '../widgets/colors.dart';

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
    // Nếu width và height được truyền, sử dụng chúng, nếu không, dùng giá trị mặc định.
    // Ví dụ: Home Screen truyền width: 140, height: 210.
    // Các nơi khác không truyền sẽ dùng giá trị mặc định (width: 220).
    final double cardWidth = width ?? 220.0;
    
    final Color semiTransparentColor = datve.withOpacity(0.7);
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
        // Ứng dụng chiều rộng được truyền vào
        width: cardWidth, 
        
        // Ứng dụng chiều cao được truyền vào. Lưu ý: Height của Container sẽ chi phối tổng chiều cao
        // Nếu height được truyền, Image.asset phải dùng Expanded hoặc kích thước tương đối.
        // Tạm thời bỏ height ở Container và điều chỉnh height của Image.asset
        // height: height, // Tạm thời bỏ để Column tự co giãn

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
                tag: movie.id, 
                child: Image.asset(
                  movie.posterUrl,
                  // Đặt chiều cao tương đối dựa trên cardWidth, hoặc dùng height được truyền vào
                  height: height != null ? height! * 0.7 : 300, 
                  width: cardWidth, // Cố định chiều rộng của ảnh
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Phần thông tin (Rating, Tên phim, Đặt vé)
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
                  
                  // Rating & Duration
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
                  
                  // Nút Đặt vé
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