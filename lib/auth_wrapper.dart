import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- THÊM: Dùng Provider
import 'package:doan_mobile/services/auth_service.dart'; // <-- Sửa đường dẫn nếu cần

// --- SỬA ĐƯỜNG DẪN MÀN HÌNH ---
import 'package:doan_mobile/screens/home/home_screen.dart';
import 'package:doan_mobile/screens/auth/login_screen.dart'; // <-- THÊM: Màn hình Login

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // SỬA: Lấy AuthService từ Provider thay vì tạo mới
    final authService = Provider.of<AuthService>(context);

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

        // SỬA LỖI: Chưa đăng nhập
        // Trả về LoginScreen thay vì HomeScreen
        return const LoginScreen();
      },
    );
  }
}
