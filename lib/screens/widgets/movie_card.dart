import 'package:flutter/material.dart';
import 'dart:ui'; // <<< CẦN THIẾT CHO BACKDROPFILTER
import '../../data/mock_Data.dart';
import '../../models/movie.dart';
import '../widgets/colors.dart';


class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  // Tạo hàm tiện ích để hiển thị SnackBar
  void _handleBooking(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Chức năng đặt vé đang phát triển...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Màu đỏ sẫm từ file colors.dart của bạn, NHƯNG thêm độ mờ (opacity)
    // Tôi giả định datve là màu đỏ sẫm. Ta sẽ dùng nó với độ trong suốt 70%.
    final Color semiTransparentColor = datve.withOpacity(0.7);

    // Độ mờ (blur) cho BackdropFilter
    const double blurSigma = 5.0;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        // ... (Giữ nguyên BoxDecoration của Card)
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
          // Poster phim
          // Giữ nguyên phần poster và thông tin phim ở đây

          // --- Phần Nút Đặt Vé Sửa Lại ---
          // Bọc lại phần thông tin phim bằng ClipRRect để có thể làm mờ
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              movie.posterUrl,
              height: 300,
              fit: BoxFit.cover,
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
                    const SizedBox(width: 12),
                    const Icon(Icons.date_range, size: 16, color: Colors.grey),
                    Text(
                      movie.releaseDate,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Nút Đặt Vé Mới - Sử dụng GestureDetector + BackdropFilter
                SizedBox(
                  width: double.infinity,
                  height: 48, // Chiều cao cố định
                  child: ClipRRect(
                    // ClipRRect để bo góc cho hiệu ứng mờ
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      // Áp dụng hiệu ứng mờ cho phần nền phía sau
                      filter: ImageFilter.blur(
                        sigmaX: blurSigma,
                        sigmaY: blurSigma,
                      ),
                      child: GestureDetector(
                        onTap: () => _handleBooking(context),
                        child: Container(
                          decoration: BoxDecoration(
                            // Màu nền với độ trong suốt
                            color: semiTransparentColor,
                            borderRadius: BorderRadius.circular(30),
                            // Thêm viền trắng mờ để tăng tính "frosted"
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
                              color:
                                  Colors.white, // Chữ trắng cho độ tương phản
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
          // --- HẾT PHẦN SỬA LỖI ---
        ],
      ),
    );
  }
}
