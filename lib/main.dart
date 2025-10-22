import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // XÓA: Không dùng SharedPreferences nữa
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// THÊM: 2 import quan trọng để khởi động Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Đảm bảo Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // THÊM: Khởi động Firebase và ĐỢI nó hoàn tất
  // Đây là dòng code sửa lỗi màn hình đỏ của bạn
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // XÓA: Toàn bộ logic SharedPreferences
  // final prefs = await SharedPreferences.getInstance();
  // final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // SỬA: Chạy MyApp mà không cần isLoggedIn
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // XÓA: Không cần biến isLoggedIn
  // final bool isLoggedIn;
  // const MyApp({super.key, required this.isLoggedIn});

  // SỬA: Constructor (hàm khởi tạo) đơn giản
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinema Booking',
      theme: AppTheme.darkTheme,
      // SỬA: 'home' bây giờ SẼ LUÔN LÀ AuthWrapper.
      // AuthWrapper sẽ tự quyết định hiển thị HomeScreen hay LoginScreen.
      home: const AuthWrapper(),
    );
  }
}

// Lớp AuthWrapper này sẽ lắng nghe trạng thái đăng nhập từ Firebase
// và tự động điều hướng người dùng
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Đang kiểm tra...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Đã đăng nhập
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Chưa đăng nhập
        return const LoginScreen();
      },
    );
  }
}
