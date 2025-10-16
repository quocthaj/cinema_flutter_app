import 'package:flutter/material.dart';
import '../widgets/colors.dart'; // file màu của bạn (sử dụng datve và ColorbuttonColor)
import '../bookings/booking_screen.dart';
import '../../models/movie.dart'; 

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  // Widget hiển thị Rating Star
  Widget _buildRating(double rating) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1), // Hiển thị 1 chữ số thập phân
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '/ 10',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // Widget hiển thị Thông tin chi tiết (Duration, Genre, Date)
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C), // Màu nền chip
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: datve, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng màu nền tối cho giao diện điện ảnh
    const Color primaryBackgroundColor = Color(0xFF1C1C1E); 
    
    // Sử dụng datve làm màu accent/chính
    final Color accentColor = datve; 

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      // Đảm bảo nút Đặt vé luôn nằm ở dưới cùng
      bottomNavigationBar: _buildBookingButton(context, accentColor),
      
      body: CustomScrollView(
        slivers: [
          // 1. SLIVER APP BAR (Ảnh và Tiêu đề)
          SliverAppBar(
            pinned: true,
            expandedHeight: 400, // Tăng chiều cao để ảnh lớn hơn
            backgroundColor: primaryBackgroundColor, 
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                movie.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 5.0, color: Colors.black)],
                ),
              ),
              background: Hero(
                tag: movie.id,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [ // Thêm bóng đổ dưới ảnh
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset( // Sửa thành Image.asset
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    height: 400,
                  ),
                ),
              ),
            ),
          ),

          // 2. SLIVER CONTENT (Thông tin chi tiết)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- A. Rating ---
                  _buildRating(movie.rating),
                  const SizedBox(height: 20),

                  // --- B. Thông tin chi tiết (Dùng Chip) ---
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildInfoChip(Icons.access_time_filled, "${movie.duration} phút"),
                        _buildInfoChip(Icons.local_activity, movie.genre),
                        _buildInfoChip(Icons.calendar_today, "KC: ${movie.releaseDate}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- C. Nội dung phim ---
                  const Text(
                    "Nội dung phim",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 15),
                  Text(
                    movie.description,
                    style: const TextStyle(
                      fontSize: 16, 
                      height: 1.5, 
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 100), // Khoảng trống cho BottomNavigationBar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Nút Đặt vé cố định ở Bottom
  Widget _buildBookingButton(BuildContext context, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), // Màu nền tối cho thanh nút
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingScreen(movie: movie),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: const Text(
              "Chọn Lịch và Đặt Vé",
              style: TextStyle(
                fontSize: 18, 
                color: Colors.white, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}