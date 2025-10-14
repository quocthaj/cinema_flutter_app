import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../data/mock_Data.dart';
import '../widgets/movie_card.dart';
import 'bottom_nav_bar.dart';
import 'custom_drawer.dart';
import 'profile_drawer.dart';
import '../widgets/colors.dart';
import '../auth/login_screen.dart';
import '../movie/movie_detail_screen.dart';
import '../movie/movie_screen.dart';
import '../../models/movie.dart';
import '../reward/reward_screen.dart';
import '../theater/theaters_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  int _currentIndex = 2;
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';
  final PageController _pageController = PageController(viewportFraction: 0.75);
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUser();
      setState(() {
        _userName = userData['userName'] ?? 'Khách';
        _userEmail = userData['userEmail'] ?? '';
        _isLoggedIn = userData.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    setState(() {
      _isLoggedIn = false;
      _userName = 'Khách';
      _userEmail = '';
    });
  }

  // ======= Lọc phim nổi bật (rating > 8) =======
  List<Movie> get featuredMovies =>
      mockMovies.where((m) => m.rating > 8.0).toList();

  // ======= Mở chi tiết phim =======
  void _openMovieDetail(Movie movie) {
    if (!_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ).then((_) => _loadUserData());
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1C1C1E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      drawer: const CustomDrawer(),
      endDrawer: ProfileDrawerDynamic(
        userName: _userName,
        userEmail: _userEmail,
        onLogout: _signOut,
      ),
      appBar: AppBar(
        backgroundColor: ColorbuttonColor,
        title: Text('Xin chào, $_userName'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                if (_isLoggedIn) {
                  Scaffold.of(context).openEndDrawer();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ).then((_) => _loadUserData());
                }
              },
            ),
          ),
        ],
      ),

      // ===================== BODY ======================
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Banner quảng cáo =====
            SizedBox(
              height: 150,
              child: PageView(
                controller: PageController(viewportFraction: 0.9),
                children: [
                  _buildBanner("lib/images/batman.jpg"),
                  _buildBanner("lib/images/AvengersEndgame.jpg"),
                  _buildBanner("lib/images/poster1.jpg"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ===== PHIM NỔI BẬT 3D CAROUSEL =====
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "🔥 Phim nổi bật",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: featuredMovies.length,
                itemBuilder: (context, index) {
                  final movie = featuredMovies[index];
                  final scale =
                      (1 - ((_currentPage - index).abs() * 0.2)).clamp(0.8, 1.0);
                  final rotation = (_currentPage - index) * 0.3;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateY(rotation)
                      ..scale(scale, scale),
                    child: GestureDetector(
                      onTap: () => _openMovieDetail(movie),
                      child: _buildFeaturedMovieCard(movie),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // ===== PHIM ĐANG CHIẾU =====
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "🎬 Phim đang chiếu",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mockMovies.length,
                itemBuilder: (context, index) {
                  final movie = mockMovies[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: GestureDetector(
                      onTap: () => _openMovieDetail(movie),
                      child: MovieCard(movie: movie),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ===================== NAVIGATION BAR ======================
      bottomNavigationBar: BottomNavBar(
        initialIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          if (index == 0) {
            // Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 1) {
            // 👉 Chuyển sang MovieScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MovieScreen()),
            );
          } else if (index == 2) {
            // Ưu đãi
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RewardScreen()),
            );
          } else if (index == 3) {
            // Rạp chiếu
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TheatersScreen()),
            );
          }
        },
      ),
    );
  }

  // ======= Widget Banner =======
  Widget _buildBanner(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }

  // ======= Widget Thẻ Phim Nổi Bật =======
  Widget _buildFeaturedMovieCard(Movie movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              movie.posterUrl,
              fit: BoxFit.cover,
              height: 250,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text("${movie.rating}",
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text("${movie.duration} phút",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _openMovieDetail(movie),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Đặt vé",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
