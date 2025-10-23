import 'package:flutter/material.dart';
import '../../config/theme.dart';
// import '../../data/mock_Data.dart'; // Bỏ mock data
import '../../models/movie.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../movie/movie_detail_screen.dart';
import '../home/home_screen.dart';
import '../reward/reward_screen.dart';
import '../theater/theaters_screen.dart';
import '../home/bottom_nav_bar.dart';
import '../news/news_and_promotions_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Đã được import qua firestore_service
import '../../services/firestore_service.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // final _authService = AuthService(); // Không cần thiết ở đây nữa
  final _firestoreService =
      FirestoreService(); // <-- THÊM: Khởi tạo FirestoreService

  // --- XÓA BIẾN NÀY ---
  // bool _isLoggedIn = false;
  int _currentIndex = 0; // ✅ "Phim" là tab đầu tiên trong thanh điều hướng

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // --- XÓA HÀM NÀY ---
    // _checkLogin();
  }

  // --- XÓA HÀM NÀY ---
  // void _checkLogin() {
  //   final user = _authService.currentUser;
  //   setState(() => _isLoggedIn = (user != null));
  // }

  // --- SỬA LẠI HÀM NÀY ---
  void _openMovie(Movie movie) {
    // --- XÓA LOGIC CHECK LOGIN ---
    // if (!_isLoggedIn) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (_) => const LoginScreen()),
    //   ).then((_) => _checkLogin()); // Kiểm tra lại login sau khi quay về
    //   return;
    // }

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
        stream: _firestoreService.getMoviesStream(), // <-- GỌI DỮ LIỆU THẬT
        builder: (context, snapshot) {
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          // Bị lỗi
          if (snapshot.hasError) {
            return Center(
              child: Text("Lỗi tải phim: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white70)),
            );
          }
          // Không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          "Không có phim nào để hiển thị",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
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
