import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Logic này của bạn đã đúng (dùng currentUser getter)
  void _checkLoginStatus() {
    try {
      final user = _authService.currentUser;
      setState(() {
        _isLoggedIn = (user != null);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Mở trailer URL
  Future<void> _openTrailer(String url) async {
    if (url.isEmpty) return;

    final Uri uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Mở trong browser/app bên ngoài
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Không thể mở link: $url"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi mở trailer: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ⭐ Widget hiển thị Rating (Giữ nguyên)
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

  // 🎬 Widget hiển thị chip thông tin (Giữ nguyên)
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

  // 🎟️ Nút đặt vé (Giữ nguyên logic của bạn, đã đúng)
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
                // Cập nhật lại trạng thái login (logic này đã đúng)
                _checkLoginStatus();
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
                  child: Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryColor));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.movie_creation_outlined,
                          color: Colors.white54, size: 50);
                    },
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
                  const SizedBox(height: 30),
                  
                  // 🎬 Trailer Section (nút mở link bên ngoài)
                  if (movie.trailerUrl.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.play_circle_outline,
                            color: AppTheme.primaryColor, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          "Trailer",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 15),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _openTrailer(movie.trailerUrl),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.3),
                              AppTheme.primaryColor.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background poster
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  movie.posterUrl,
                                  fit: BoxFit.cover,
                                  color: Colors.black.withOpacity(0.7),
                                  colorBlendMode: BlendMode.darken,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primaryColor
                                      )
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppTheme.cardColor,
                                      child: const Center(
                                        child: Icon(
                                          Icons.movie_creation_outlined,
                                          color: Colors.white54,
                                          size: 40
                                        )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Play button
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Xem Trailer",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
