import 'package:flutter/material.dart';
import '../widgets/colors.dart';
import '../bookings/booking_screen.dart';
import '../../models/movie.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final userData = await _authService.getCurrentUser();
      setState(() {
        _isLoggedIn = userData.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ⭐ Widget hiển thị Rating
  Widget _buildRating(double rating) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        const Text('/10', style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  // 🎬 Widget hiển thị chip thông tin
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: datve, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  // 🎟️ Nút đặt vé (chỉ kiểm tra khi nhấn)
  Widget _buildBookingButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
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
            onPressed: () async {
              if (!_isLoggedIn) {
                // Nếu chưa đăng nhập → chuyển đến LoginScreen
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                await _checkLoginStatus(); // Cập nhật lại sau khi login
              } else {
                // Nếu đã đăng nhập → đến BookingScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(movie: widget.movie),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: datve,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              "🎟️ Chọn Lịch & Đặt Vé",
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

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF1C1C1E);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    final movie = widget.movie;

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: _buildBookingButton(context),
      body: CustomScrollView(
        slivers: [
          // 🔺 ẢNH + APPBAR
          SliverAppBar(
            pinned: true,
            expandedHeight: 400,
            backgroundColor: bgColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                movie.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                ),
              ),
              background: Hero(
                tag: movie.id,
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ).createShader(rect),
                  blendMode: BlendMode.darken,
                  child: Image.asset(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Nội dung
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRating(movie.rating),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
