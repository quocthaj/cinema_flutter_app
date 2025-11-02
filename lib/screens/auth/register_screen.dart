import 'package:doan_mobile/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- THÊM: Để bắt lỗi Firebase
import 'package:flutter/material.dart';
import '/services/auth_service.dart'; // <-- Thay 'movie_app' bằng tên dự án
// import '../home/home_screen.dart'; // KHÔNG CẦN import HomeScreen ở đây
import '/config/theme.dart'; // <-- Thêm import cho AppTheme

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    // Ẩn bàn phím trước khi xử lý
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Gọi hàm signUpWithEmailAndPassword từ Firebase AuthService
        final user = await _authService.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(), // Truyền displayName vào đây
        );

        // Kiểm tra widget còn tồn tại không trước khi thao tác Context
        if (mounted && user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Đang tự động đăng nhập...'),
              backgroundColor: Colors.green,
            ),
          );
          // Không cần pushReplacement vì AuthWrapper sẽ tự điều hướng.
          // Pop màn hình này để quay lại màn hình trước (thường là Login),
          // AuthWrapper sẽ tự chuyển sang HomeScreen.
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        }
        // Trường hợp user == null (thường không xảy ra nếu không có exception,
        // nhưng để an toàn có thể thêm xử lý ở đây nếu cần)
      } on FirebaseAuthException catch (e) {
        // Bắt lỗi cụ thể từ Firebase
        String errorMessage = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
        if (e.code == 'weak-password') {
          errorMessage = 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage =
              'Địa chỉ email này đã được sử dụng bởi tài khoản khác.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Địa chỉ email không hợp lệ.';
        } else {
          errorMessage =
              e.message ?? errorMessage; // Lấy thông báo lỗi từ Firebase nếu có
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent, // Màu đỏ nhạt hơn chút
            ),
          );
        }
      } catch (e) {
        // Bắt các lỗi chung khác (ví dụ: lỗi mạng)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xảy ra lỗi: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        // Đảm bảo dừng loading dù thành công hay thất bại, chỉ khi widget còn tồn tại
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng màu nền từ theme hoặc màu mặc định nếu AppTheme chưa có
    final Color backgroundColor =
        AppTheme.darkTheme.scaffoldBackgroundColor; // Giả sử bạn có darkTheme
    final Color primaryColor =
        AppTheme.primaryColor; // Giả sử bạn có primaryColor
    final Color hintColor = Colors.grey[400] ?? Colors.grey;
    final Color inputFillColor =
        Colors.grey[900] ?? Colors.black.withOpacity(0.1);
    final Color inputBorderColor = Colors.grey[700] ?? Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Nền trong suốt
        elevation: 0, // Không có bóng đổ
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white), // Icon màu trắng
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại', // Thêm tooltip
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          // Thêm GestureDetector để ẩn bàn phím
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Icon(
                    Icons.person_add_outlined,
                    size: 80,
                    color: primaryColor,
                  ),

                  const SizedBox(height: 24),

                  // Tiêu đề
                  Text(
                    'Đăng Ký',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          // Dùng headlineMedium
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Tạo tài khoản mới để bắt đầu',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          // Dùng bodyLarge
                          color: hintColor,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization:
                        TextCapitalization.words, // Tự viết hoa chữ cái đầu
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      labelStyle: TextStyle(color: hintColor),
                      prefixIcon: Icon(Icons.person_outline,
                          color: primaryColor), // Icon outline
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        // Thêm trim()
                        return 'Vui lòng nhập họ tên';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: hintColor),
                      prefixIcon:
                          Icon(Icons.email_outlined, color: primaryColor),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      // Regex đơn giản để kiểm tra định dạng email
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      labelStyle: TextStyle(color: hintColor),
                      prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined, // Icon outline
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu',
                      labelStyle: TextStyle(color: hintColor),
                      prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword =
                              !_obscureConfirmPassword);
                        },
                      ),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      if (value != _passwordController.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Register button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // Thêm hiệu ứng khi disable
                      disabledBackgroundColor: primaryColor.withOpacity(0.5),
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
                            'Đăng Ký',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Đảm bảo chữ màu trắng
                            ),
                          ),
                  ),
                  const SizedBox(
                      height:
                          16), // Thêm khoảng cách trước text "Đã có tài khoản?"
                  // Link quay lại đăng nhập
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: TextStyle(color: hintColor),
                      ),
                      TextButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(
                                context); // Quay lại màn hình trước đó (Login)
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // Bỏ padding mặc định
                          minimumSize: Size.zero, // Bỏ size mặc định
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // Thu nhỏ vùng chạm
                        ),
                        child: Text(
                          'Đăng nhập ngay',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
