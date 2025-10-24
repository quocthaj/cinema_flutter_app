import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/featured_movies_carousel.dart';
import '../widgets/banner_carousel.dart';
import 'bottom_nav_bar.dart';
import 'custom_drawer.dart';
import 'profile_drawer.dart';
import '../auth/login_screen.dart';
import '../movie/movie_detail_screen.dart';
import '../movie/movie_screen.dart';
import '../reward/reward_screen.dart';
import '../theater/theaters_screen.dart';
import '../news/news_and_promotions_screen.dart';
import '../../config/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../admin/seed_data_screen.dart'; // 🆕 THÊM IMPORT NÀY

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  int _currentIndex = 2;

  bool _isLoggedIn = false;
  bool _isLoadingUserData = true;

  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    try {
      final User? user = _authService.currentUser;
      setState(() {
        if (user != null) {
          _userName = user.displayName ?? 'Bạn';
          _userEmail = user.email ?? '';
          _isLoggedIn = true;
        } else {
          _userName = 'Khách';
          _userEmail = '';
          _isLoggedIn = false;
        }
        _isLoadingUserData = false;
      });
    } catch (e) {
      setState(() {
        _userName = 'Khách';
        _userEmail = '';
        _isLoggedIn = false;
        _isLoadingUserData = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

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
    if (_isLoadingUserData) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    return Scaffold(
      drawer: const CustomDrawer(),
      endDrawer: ProfileDrawerDynamic(
        userName: _userName,
        userEmail: _userEmail,
        onLogout: _signOut,
      ),
      appBar: AppBar(
        title: Text(
          "Xin chào, $_userName ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
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
      body: StreamBuilder<List<Movie>>(
        stream: _firestoreService.getMoviesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Lỗi tải phim: ${snapshot.error}",
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Hiện chưa có phim nào.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final allMovies = snapshot.data!;
          final featuredMovies =
              allMovies.where((m) => m.rating >= 8.0).toList();
          final nowShowingMovies =
              allMovies.where((m) => m.status == 'now_showing').toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BannerCarousel(
                  banners: [
                    'lib/images/banner1.jpg',
                    'lib/images/banner2.jpg',
                    'lib/images/banner3.jpg',
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    " Phim nổi bật",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                FeaturedMoviesCarousel(
                  movies: featuredMovies,
                  onMovieTap: _openMovieDetail,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    " Phim đang chiếu",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                nowShowingMovies.isNotEmpty
                    ? SizedBox(
                        height: 340,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: nowShowingMovies.length,
                          itemBuilder: (context, index) {
                            final movie = nowShowingMovies[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index == nowShowingMovies.length - 1
                                    ? 0
                                    : 12,
                              ),
                              child: GestureDetector(
                                onTap: () => _openMovieDetail(movie),
                                child: MovieCard(movie: movie),
                              ),
                            );
                          },
                        ),
                      )
                    : const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Text(
                          "Chưa có phim đang chiếu.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
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
            // Current page
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
      // 🆕 THÊM FLOATING ACTION BUTTON ĐỂ MỞ ADMIN SCREEN
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SeedDataScreen(),
            ),
          );
        },
        icon: const Icon(Icons.admin_panel_settings),
        label: const Text('Admin'),
        backgroundColor: Colors.deepPurple,
        tooltip: 'Mở Admin Panel để seed dữ liệu',
      ),
    );
  }
}
