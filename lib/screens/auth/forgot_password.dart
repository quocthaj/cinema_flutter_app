import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// SỬA LẠI ĐƯỜNG DẪN IMPORT
import '/services/auth_service.dart'; // <-- Thay 'movie_app' bằng tên dự án

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // SỬA: Gọi hàm sendPasswordResetEmail của Firebase
        await _authService.sendPasswordResetEmail(_emailController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // SỬA: Cập nhật thông báo cho chính xác
              content: const Text(
                  'Đã gửi email khôi phục mật khẩu. Vui lòng kiểm tra hộp thư!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        // SỬA: Bắt lỗi từ Firebase
        String errorMessage = 'Email không tồn tại hoặc không hợp lệ.';
        if (e.code == 'user-not-found') {
          errorMessage = 'Không tìm thấy tài khoản nào với email này.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Email không hợp lệ.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xảy ra lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Toàn bộ UI của bạn được giữ nguyên
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Thêm nút back
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Colors.redAccent,
                ),

                const SizedBox(height: 24),

                // Tiêu đề
                const Text(
                  'Quên Mật Khẩu?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Nhập email của bạn để nhận link khôi phục', // Sửa text
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Colors.redAccent),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.redAccent, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Send button
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Gửi Email Khôi Phục', // Sửa text
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // Back to login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(color: Colors.redAccent),
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
