import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// AuthService không dùng Firebase - Lưu trữ local
/// Lưu ý: Đây chỉ là demo, không bảo mật cho production
class AuthService {
  // Key để lưu trong SharedPreferences
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'isLoggedIn';

  // Đăng ký bằng email và password
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Lấy danh sách user đã đăng ký
      List<Map<String, dynamic>> users = await _getRegisteredUsers();
      
      // Kiểm tra email đã tồn tại chưa
      bool emailExists = users.any((user) => user['email'] == email);
      if (emailExists) {
        throw Exception('Email đã được sử dụng');
      }
      
      // Validate password
      if (password.length < 6) {
        throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
      }
      
      // Tạo user mới
      Map<String, dynamic> newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'password': _hashPassword(password), // Mã hóa đơn giản
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Thêm vào danh sách
      users.add(newUser);
      
      // Lưu lại
      await prefs.setString(_usersKey, jsonEncode(users));
      
      // Tự động đăng nhập sau khi đăng ký
      await _saveCurrentUser(newUser);
      
      return true;
    } catch (e) {
      print('Lỗi đăng ký: $e');
      rethrow;
    }
  }

  // Đăng nhập bằng email và password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      // Lấy danh sách user
      List<Map<String, dynamic>> users = await _getRegisteredUsers();
      
      // Tìm user với email và password khớp
      Map<String, dynamic>? user = users.firstWhere(
        (user) => user['email'] == email && user['password'] == _hashPassword(password),
        orElse: () => {},
      );
      
      if (user.isEmpty) {
        throw Exception('Email hoặc mật khẩu không đúng');
      }
      
      // Lưu thông tin đăng nhập
      await _saveCurrentUser(user);
      
      return true;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      rethrow;
    }
  }

  // Kiểm tra trạng thái đăng nhập
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Lấy thông tin user hiện tại
  Future<Map<String, String>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_currentUserKey);
    
    if (userJson == null) {
      return {
        'userId': '',
        'userEmail': '',
        'userName': '',
      };
    }
    
    Map<String, dynamic> user = jsonDecode(userJson);
    return {
      'userId': user['id'] ?? '',
      'userEmail': user['email'] ?? '',
      'userName': user['name'] ?? '',
    };
  }

  // Đăng xuất
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Quên mật khẩu (giả lập - không gửi email thật)
  Future<void> resetPassword(String email) async {
    try {
      List<Map<String, dynamic>> users = await _getRegisteredUsers();
      
      // Kiểm tra email có tồn tại không
      bool emailExists = users.any((user) => user['email'] == email);
      
      if (!emailExists) {
        throw Exception('Email không tồn tại trong hệ thống');
      }
      
      // Trong thực tế, bạn sẽ gửi email ở đây
      // Đây chỉ là giả lập
      print('Email reset password đã được gửi đến: $email');
      
    } catch (e) {
      print('Lỗi reset password: $e');
      rethrow;
    }
  }

  // Thay đổi mật khẩu
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString(_currentUserKey);
      
      if (userJson == null) {
        throw Exception('Chưa đăng nhập');
      }
      
      Map<String, dynamic> currentUser = jsonDecode(userJson);
      
      // Kiểm tra mật khẩu cũ
      if (currentUser['password'] != _hashPassword(oldPassword)) {
        throw Exception('Mật khẩu cũ không đúng');
      }
      
      // Validate mật khẩu mới
      if (newPassword.length < 6) {
        throw Exception('Mật khẩu mới phải có ít nhất 6 ký tự');
      }
      
      // Cập nhật mật khẩu
      List<Map<String, dynamic>> users = await _getRegisteredUsers();
      int index = users.indexWhere((user) => user['id'] == currentUser['id']);
      
      if (index != -1) {
        users[index]['password'] = _hashPassword(newPassword);
        await prefs.setString(_usersKey, jsonEncode(users));
        
        // Cập nhật current user
        currentUser['password'] = _hashPassword(newPassword);
        await prefs.setString(_currentUserKey, jsonEncode(currentUser));
      }
      
    } catch (e) {
      print('Lỗi đổi mật khẩu: $e');
      rethrow;
    }
  }

  // Cập nhật thông tin profile
  Future<void> updateProfile(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString(_currentUserKey);
      
      if (userJson == null) {
        throw Exception('Chưa đăng nhập');
      }
      
      Map<String, dynamic> currentUser = jsonDecode(userJson);
      
      // Cập nhật tên
      List<Map<String, dynamic>> users = await _getRegisteredUsers();
      int index = users.indexWhere((user) => user['id'] == currentUser['id']);
      
      if (index != -1) {
        users[index]['name'] = name;
        await prefs.setString(_usersKey, jsonEncode(users));
        
        // Cập nhật current user
        currentUser['name'] = name;
        await prefs.setString(_currentUserKey, jsonEncode(currentUser));
      }
      
    } catch (e) {
      print('Lỗi cập nhật profile: $e');
      rethrow;
    }
  }

  // === PRIVATE METHODS ===

  // Lấy danh sách user đã đăng ký
  Future<List<Map<String, dynamic>>> _getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString(_usersKey);
    
    if (usersJson == null) {
      return [];
    }
    
    List<dynamic> decoded = jsonDecode(usersJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  // Lưu user hiện tại
  Future<void> _saveCurrentUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user));
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Mã hóa password đơn giản (KHÔNG AN TOÀN cho production)
  // Trong thực tế nên dùng bcrypt hoặc argon2
  String _hashPassword(String password) {
    // Đây chỉ là mã hóa cơ bản để demo
    // KHÔNG dùng cho production thật
    String salt = 'cinema_app_salt_2024';
    return base64Encode(utf8.encode(password + salt));
  }

  // Xóa tất cả dữ liệu (cho testing)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
    await prefs.remove(_isLoggedInKey);
  }
}