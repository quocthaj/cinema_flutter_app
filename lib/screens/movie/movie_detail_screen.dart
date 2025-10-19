import 'package:flutter/material.dart';
import '../../config/theme.dart';
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
        Icon(Icons.star_rounded, color: AppTheme.goldColor, size: 28),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
        ),
        const SizedBox(width: 4),
        Text('/10', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  // 🎬 Widget hiển thị chip thông tin
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: AppTheme.fieldColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  // 🎟️ Nút đặt vé (chỉ kiểm tra khi nhấn)
  Widget _buildBookingButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
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
            child: const Text(
              "🎟️ Chọn Lịch & Đặt Vé",
              style: TextStyle(
                fontSize: 18,
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
    if (_isLoading) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    final movie = widget.movie;

    return Scaffold(
      bottomNavigationBar: _buildBookingButton(context),
      body: CustomScrollView(
        slivers: [
          // 🔺 ẢNH + APPBAR
          SliverAppBar(
            pinned: true,
            expandedHeight: 400,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                movie.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                        _buildInfoChip(
                            Icons.access_time_filled, "${movie.duration} phút"),
                        _buildInfoChip(Icons.local_activity, movie.genre),
                        _buildInfoChip(
                            Icons.calendar_today, "KC: ${movie.releaseDate}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Nội dung phim",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(color: Colors.white12, height: 15),
                  Text(
                    movie.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.5),
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
