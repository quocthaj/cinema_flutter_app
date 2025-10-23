import 'package:doan_mobile/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // XÓA: Không dùng SharedPreferences nữa
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Đảm bảo Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  //Khởi tạo firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

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
        return const HomeScreen();
      },
    );
  }
}

// Cấu hình EasyLoading (tùy chỉnh theo ý bạn)
void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black87
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}
