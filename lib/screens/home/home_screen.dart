import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import '../../services/auth_service.dart';
import '../../data/mock_Data.dart';
import '../../models/movie.dart';
import '../widgets/movie_card.dart';
import 'bottom_nav_bar.dart';
import 'custom_drawer.dart';
import 'profile_drawer.dart';
import '../widgets/colors.dart';
import '../auth/login_screen.dart';
import '../movie/movie_detail_screen.dart';
import '../movie/movie_screen.dart';
import '../reward/reward_screen.dart';
import '../theater/theaters_screen.dart';
import '../news/news_and_promotions_screen.dart';

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

  int _currentBanner = 0;
  final PageController _pageController = PageController(viewportFraction: 0.75);
  double _currentPage = 0.0;

  final List<String> _banners = [
    'lib/images/banner1.jpg',
    'lib/images/banner2.jpg',
    'lib/images/banner3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page ?? 0);
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

  List<Movie> get featuredMovies =>
      mockMovies.where((m) => m.rating >= 8.0).toList();

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

      // ====== APPBAR ======
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Xin chào, $_userName 👋",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
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

      // ====== BODY ======
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Banner Auto Slide
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    height: 200,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    autoPlayInterval: const Duration(seconds: 4),
                    onPageChanged: (index, _) {
                      setState(() => _currentBanner = index);
                    },
                  ),
                  items: _banners.map((img) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _banners.asMap().entries.map((entry) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentBanner == entry.key ? 10 : 6,
                      height: 6,
                      margin:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentBanner == entry.key
                            ? Colors.redAccent
                            : Colors.white38,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🎬 PHIM NỔI BẬT
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "🔥 Phim nổi bật",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

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

            const SizedBox(height: 24),

            // 🎥 PHIM ĐANG CHIẾU
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "🎥 Phim đang chiếu",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mockMovies.length,
                itemBuilder: (context, index) {
                  final movie = mockMovies[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () => _openMovieDetail(movie),
                      child: MovieCard(movie: movie),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // ====== BOTTOM NAV ======
      bottomNavigationBar: BottomNavBar(
        initialIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MovieScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RewardScreen()),
            );
          } else if (index == 2) {
            // Trang hiện tại
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TheatersScreen()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NewsAndPromotionsPage()),
            );
          }
        },
      ),
    );
  }

  // ====== Thẻ phim nổi bật ======
  Widget _buildFeaturedMovieCard(Movie movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.asset(
              movie.posterUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  child: const Text("🎟️ Đặt vé",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
