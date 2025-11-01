import 'package:doan_mobile/screens/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
// <-- not required but fine
import '../../config/theme.dart';
import '../../models/movie.dart';
import '../movie/movie_detail_screen.dart';
import '../home/home_screen.dart';
import '../reward/reward_screen.dart';
import '../theater/theaters_screen.dart';
import '../home/bottom_nav_bar.dart';
import '../news/news_and_promotions_screen.dart';
import '../../services/firestore_service.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firestoreService = FirestoreService();
  int _currentIndex = 0; // ✅ "Phim" là tab đầu tiên trong thanh điều hướng

  // Thêm trạng thái loading cho shimmer
  bool _isLoading = true;

  // Trả về màu tương ứng cho ageRating
  Color _ageRatingColor(String? rating) {
    if (rating == null || rating.isEmpty) return Colors.grey;
    final r = rating.toUpperCase();
    if (r == 'P') return Colors.green; // Phù hợp mọi lứa tuổi
    if (r == 'K') return Colors.blue; // Khán giả nhỏ tuổi
    if (r.startsWith('T')) {
      if (r.contains('18')) return Colors.red;
      if (r.contains('16')) return Colors.deepOrange;
      if (r.contains('13')) return Colors.amber;
      return Colors.orange;
    }
    return Colors.grey;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // --- SỬA LẠI HÀM NÀY ---
  void _openMovie(Movie movie) {
    // LUÔN ĐI THẲNG VÀO MOVIE DETAIL
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🎬 Danh sách phim",
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Phim đang chiếu"),
            Tab(text: "Phim sắp chiếu"),
          ],
        ),
      ),
      // SỬA: Thay thế body bằng StreamBuilder
      body: StreamBuilder<List<Movie>>(
        stream: _firestoreService.getMoviesStream(),
        builder: (context, snapshot) {
          // Nếu vừa có dữ liệu, tắt shimmer (sử dụng addPostFrame để không setState trong build)
          if (snapshot.hasData && _isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _isLoading = false);
            });
          }

          if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
            return Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          if (snapshot.hasError) {
            // Nếu lỗi, cũng tắt shimmer để hiển thị lỗi
            if (_isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() => _isLoading = false);
              });
            }
            return Center(
              child: Text("Lỗi tải phim: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white70)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            if (_isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() => _isLoading = false);
              });
            }
            return const Center(
              child: Text(
                "Không có phim nào để hiển thị",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          // KHI CÓ DỮ LIỆU: Lọc danh sách phim (giống logic cũ của bạn)
          final allMovies = snapshot.data!;
          final nowShowing =
              allMovies.where((m) => m.status == 'now_showing').toList();
          final comingSoon =
              allMovies.where((m) => m.status == 'coming_soon').toList();

          // Trả về TabBarView với dữ liệu thật
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMovieGrid(nowShowing),
              _buildMovieGrid(comingSoon),
            ],
          );
        },
      ),

      // ✅ Thanh điều hướng dưới cùng (giữ nguyên)
      bottomNavigationBar: BottomNavBar(
        initialIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          if (index == 0) {
            // 👉 Phim (hiện tại)
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RewardScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TheatersScreen()),
            );
          } else if (index == 4) {
            // Tab khuyến mãi (nếu có)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NewsAndPromotionsPage()),
            );
          }
        },
      ),
    );
  }

  // ======= Lưới phim (2 cột) =======
  // (Giữ nguyên logic của bạn)
  Widget _buildMovieGrid(List<Movie> movies) {
    if (!_isLoading && movies.isEmpty) {
      return const Center(
        child: Text(
          "Không có phim nào để hiển thị",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    if (_isLoading) {
      // hiển thị shimmer placeholders
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Hiển thị 2 cột
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const MovieCardShimmer();
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Hiển thị 2 cột
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieCard(movie);
      },
    );
  }

  // ======= Thẻ phim =======
  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => _openMovie(movie), // Hàm _openMovie đã được sửa
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ảnh phim
            Expanded(
              child: Hero(
                tag: movie.id, // SỬA: Dùng movie.id (luôn duy nhất)
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  // SỬA: Dùng Image.network để tải ảnh từ link
                  child: Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    // THÊM: Hiển thị loading và xử lý lỗi
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryColor));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.movie_creation_outlined,
                          color: Colors.white54, size: 40);
                    },
                  ),
                ),
              ),
            ),

            // Thông tin phim
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${movie.rating}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Hiển thị duration và ageRating (với màu sắc khác nhau cho ageRating)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            "${movie.duration} phút",
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      if ((movie.ageRating ?? '').isNotEmpty)
                        Chip(
                          backgroundColor: _ageRatingColor(movie.ageRating),
                          label: Text(
                            movie.ageRating ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: ElevatedButton(
                      onPressed: () =>
                          _openMovie(movie), // Hàm _openMovie đã được sửa
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        "Đặt vé",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
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
