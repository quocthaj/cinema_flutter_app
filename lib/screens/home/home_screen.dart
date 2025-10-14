import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../data/mock_Data.dart';
import '../widgets/movie_card.dart';
import 'bottom_nav_bar.dart';
import 'custom_drawer.dart';
import 'profile_drawer.dart';
import '../widgets/colors.dart';
import '../auth/login_screen.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../../models/movie.dart';
import '../reward/reward_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  int _currentIndex = 2;
  int _selectedTabIndex = 0; // 0: Đang chiếu, 1: Sắp chiếu, 2: Khuyến av
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUser();
      setState(() {
        _userName = userData['userName'] ?? 'User';
        _userEmail = userData['userEmail'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('Xác nhận đăng xuất', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?', style: TextStyle(color: Color.fromARGB(179, 146, 70, 70))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi đăng xuất: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1C1C1E),
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
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
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),

      // ===================== BODY ======================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Thanh danh mục ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryTab("Đang chiếu", 0),
                _buildCategoryTab("Sắp chiếu", 1),
                _buildCategoryTab("Khuyến mãi", 2),
              ],
            ),
            const SizedBox(height: 16),

            // === Banner phim nổi bật ===
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Tags ---
                  Row(
                    children: [
                      _buildTag("HOT", Colors.redAccent),
                      const SizedBox(width: 8),
                      _buildTag("IMAX", Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- Tiêu đề ---
                  const Text(
                    "Avatar: The Way of Water",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Hành trình kỳ thú dưới đại dương Pandora",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),

                  // --- Hình ảnh phim ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "lib/images/AvengersEndgame.jpg", // Thay bằng link hình ảnh thật
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- Rating & Thời lượng ---
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text("8.9", style: TextStyle(color: Colors.white)),
                      SizedBox(width: 12),
                      Text("192 phút", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // --- Nút đặt vé ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Movie avatarMovie = Movie.fromJson({
                          'id': '1',
                          'title': 'Avatar: The Way of Water',
                          'genre': 'Sci-Fi',
                          'duration': 192,
                          'rating': 8.9,
                          'posterUrl': "lib/images/AvengersEndgame.jpg",
                          'status': 'now_showing',
                          'releaseDate': '2025-12-20',
                          'description': 'Hành trình kỳ thú dưới đại dương Pandora',
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movie: avatarMovie),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text("Đặt vé ngay"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // === Danh sách phim ===
            const Text(
              "🎬 Phim đang chiếu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 500,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mockMovies.length,
                itemBuilder: (context, index) {
                  final movie = mockMovies[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      child: MovieCard(movie: movie),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ===================== BOTTOM BAR ======================
      bottomNavigationBar: BottomNavBar(
        initialIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Mở trang Reward
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RewardScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),


    );
  }

  // === Widget tab danh mục ===
  Widget _buildCategoryTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.redAccent : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // === Widget tag (HOT, IMAX) ===
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}




