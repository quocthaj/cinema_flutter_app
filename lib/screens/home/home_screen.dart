import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import '../../services/auth_service.dart';
// import '../../data/mock_Data.dart'; // Bỏ mock data
import '../../models/movie.dart';
import '../widgets/movie_card.dart';
import 'bottom_nav_bar.dart';
import 'custom_drawer.dart';
// --- 1. SỬA IMPORT NÀY ---
import 'profile_drawer.dart'; // Trỏ đến file trong Canvas
import '../auth/login_screen.dart';
import '../movie/movie_detail_screen.dart';
import '../movie/movie_screen.dart';
import '../reward/reward_screen.dart';
import '../theater/theaters_screen.dart';
import '../news/news_and_promotions_screen.dart';
import '../../config/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  int _currentIndex = 2; // Home là tab giữa

  // --- BỎ CÁC BIẾN STATE NÀY (sẽ được quản lý bởi StreamBuilder) ---
  // bool _isLoggedIn = false;
  // bool _isLoadingUserData = true;
  // String _userName = '';
  // String _userEmail = '';

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
    // Bỏ _loadUserData();
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page ?? 0);
    });
  }

  // --- BỎ HÀM _loadUserData() ---
  // void _loadUserData() { ... }

  Future<void> _signOut() async {
    await _authService.signOut();
    // AuthWrapper (nếu có) hoặc StreamBuilder sẽ tự xử lý
  }

  // Sửa: Bỏ 'isLoggedIn' ra khỏi hàm này
  void _openMovieDetail(Movie movie) {
    // Luôn đi thẳng vào MovieDetailScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- 2. THÊM STREAMBUILDER CHO AUTH STATE ---
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Trạng thái loading auth
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        // Lấy thông tin user từ snapshot
        final User? user = authSnapshot.data;
        final bool isLoggedIn = user != null;
        final String userName = user?.displayName ?? 'Khách';
        final String userEmail = user?.email ?? 'Vui lòng đăng nhập';

        // Trả về Scaffold chính
        return Scaffold(
          drawer: const CustomDrawer(),

          // --- 3. CẬP NHẬT ENDDRAWER ---
          endDrawer: ProfileDrawerDynamic(
            userName: userName,
            userEmail: userEmail,
            onLogout: _signOut,
            isLoggedIn: isLoggedIn, // <-- ĐÃ THÊM BIẾN NÀY
          ),

          appBar: AppBar(
            centerTitle: true,
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    if (isLoggedIn) {
                      // Dùng biến isLoggedIn mới nhất
                      Scaffold.of(context).openEndDrawer();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                      // Bỏ .then()
                    }
                  },
                ),
              ),
            ],
          ),

          // ====== BODY (Dùng StreamBuilder cho Movies) ======
          body: StreamBuilder<List<Movie>>(
            stream: _firestoreService.getMoviesStream(),
            builder: (context, movieSnapshot) {
              // Trạng thái tải phim
              if (movieSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryColor));
              }
              // Lỗi tải phim
              if (movieSnapshot.hasError) {
                return Center(
                    child: Text("Lỗi tải phim: ${movieSnapshot.error}",
                        style: const TextStyle(color: Colors.white70)));
              }
              // Không có phim
              if (!movieSnapshot.hasData || movieSnapshot.data!.isEmpty) {
                return const Center(
                    child: Text("Hiện chưa có phim nào.",
                        style: TextStyle(color: Colors.white70)));
              }

              // KHI CÓ DỮ LIỆU PHIM: Lọc ra danh sách
              final allMovies = movieSnapshot.data!;
              final featuredMovies =
                  allMovies.where((m) => m.rating >= 8.0).toList();
              final nowShowingMovies =
                  allMovies.where((m) => m.status == 'now_showing').toList();

              // Trả về nội dung chính của trang chủ
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 Banner Auto Slide (Giữ nguyên)
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
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentBanner == entry.key
                                    ? AppTheme.primaryColor
                                    : Colors.white38,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🎬 PHIM NỔI BẬT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "🔥 Phim nổi bật",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),

                    featuredMovies.isNotEmpty
                        ? SizedBox(
                            height: 444, // Chiều cao khít với card
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: featuredMovies.length * 1000,
                              itemBuilder: (context, index) {
                                final actualIndex =
                                    index % featuredMovies.length;
                                final movie = featuredMovies[actualIndex];
                                final movieNumber = actualIndex + 1;

                                final scale =
                                    (1 - ((_currentPage - index).abs() * 0.2))
                                        .clamp(0.8, 1.0);
                                final rotation = (_currentPage - index) * 0.3;

                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateY(rotation)
                                    ..scale(scale, scale),
                                  child: GestureDetector(
                                    // Sửa: Bỏ isLoggedIn
                                    onTap: () => _openMovieDetail(movie),
                                    child: _buildFeaturedMovieCard(
                                        movie, movieNumber),
                                  ),
                                );
                              },
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            child: Text("Chưa có phim nổi bật.",
                                style: TextStyle(color: Colors.white70)),
                          ),

                    const SizedBox(height: 24),

                    // 🎥 PHIM ĐANG CHIẾU
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "🎥 Phim đang chiếu",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),

                    nowShowingMovies.isNotEmpty
                        ? SizedBox(
                            height: 320, // Chiều cao của MovieCard
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: nowShowingMovies.length,
                              itemBuilder: (context, index) {
                                final movie = nowShowingMovies[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: 16,
                                    right: index == nowShowingMovies.length - 1
                                        ? 16
                                        : 0,
                                  ),
                                  child: GestureDetector(
                                    // Sửa: Bỏ isLoggedIn
                                    onTap: () => _openMovieDetail(movie),
                                    child: MovieCard(movie: movie),
                                  ),
                                );
                              },
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            child: Text("Chưa có phim đang chiếu.",
                                style: TextStyle(color: Colors.white70)),
                          ),

                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),

          // ====== BOTTOM NAV (Giữ nguyên) ======
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
                  MaterialPageRoute(
                      builder: (_) => const NewsAndPromotionsPage()),
                );
              }
            },
          ),
        );
      },
    );
  }

  // ====== Thẻ phim nổi bật với Ticket Shape ======
  Widget _buildFeaturedMovieCard(Movie movie, int movieNumber) {
    return Container(
      // Bỏ GestureDetector ở đây vì đã bọc ở PageView
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      height: 428,
      child: ClipPath(
        clipper: TicketCardClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF9B3232).withOpacity(0.3),
                const Color(0xFF9B3232).withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(3), // Viền gradient
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // === PHẦN TRÊN: Poster + Số ===
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        movie.posterUrl,
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return SizedBox(
                              height: 280,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: AppTheme.primaryColor)));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                              height: 280,
                              child: Icon(Icons.movie_creation_outlined,
                                  color: Colors.white54, size: 50));
                        },
                      ),
                    ),
                    // Số thứ tự
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$movieNumber',
                            style: const TextStyle(
                              color: Color(0xFF9B3232),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // === PHẦN GIỮA: Thông tin phim ===
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF9B3232).withOpacity(0.85),
                        const Color(0xFF9B3232).withOpacity(0.95),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        movie.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFFD700), size: 15),
                          const SizedBox(width: 3),
                          Text(
                            "${movie.rating}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.access_time,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            "${movie.duration} Phút",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            movie.releaseDate,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // === ĐƯỜNG PHÂN CÁCH ===
                CustomPaint(
                  size: const Size(double.infinity, 2),
                  painter: DashedLinePainter(),
                ),

                // === PHẦN DƯỚI: Button Đặt vé ===
                Container(
                  height: 78,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF9B3232),
                        Color(0xFF7A2828),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      // Sửa: Bỏ isLoggedIn (cũng là để sửa bug)
                      onTap: () => _openMovieDetail(movie),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: Center(
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: const Text(
                            "Đặt vé",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
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
        ),
      ),
    );
  }
}

// Các lớp Clipper và Painter giữ nguyên...
class TicketCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double cornerRadius = 20.0;
    const double notchRadius = 8.0;
    const int notchCountVertical = 10;

    // Top left corner
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Top edge
    path.lineTo(size.width - cornerRadius, 0);

    // Top right corner
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Right edge with notches
    final double notchHeightRight =
        (size.height - 2 * cornerRadius) / notchCountVertical;
    for (int i = 0; i <= notchCountVertical; i++) {
      final double y = cornerRadius + i * notchHeightRight;
      if (i > 0) {
        path.lineTo(size.width, y - notchHeightRight / 2 - notchRadius);
        path.arcToPoint(
          Offset(size.width, y - notchHeightRight / 2 + notchRadius),
          radius: const Radius.circular(notchRadius),
          clockwise: false,
        );
      }
      if (i < notchCountVertical) {
        path.lineTo(size.width, y + notchHeightRight / 2);
      }
    }

    // Bottom right corner
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    // Bottom edge
    path.lineTo(cornerRadius, size.height);

    // Bottom left corner
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    // Left edge with notches
    for (int i = notchCountVertical; i >= 0; i--) {
      final double y = cornerRadius + i * notchHeightRight;
      if (i < notchCountVertical) {
        path.lineTo(0, y + notchHeightRight / 2 + notchRadius);
        path.arcToPoint(
          Offset(0, y + notchHeightRight / 2 - notchRadius),
          radius: const Radius.circular(notchRadius),
          clockwise: false,
        );
      }
      if (i > 0) {
        path.lineTo(0, y - notchHeightRight / 2);
      }
    }

    path.lineTo(0, cornerRadius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom Painter cho đường phân cách nét đứt
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5;

    const double dashWidth = 8;
    const double dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
