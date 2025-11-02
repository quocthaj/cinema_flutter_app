import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart'; // <-- Thay 'movie_app' bằng tên dự án của bạn
import 'admin_service.dart'; // 🔥 ADMIN: Import AdminService

class AuthService {
  // Khởi tạo các dịch vụ Firebase cần thiết
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final AdminService _adminService = AdminService(); // 🔥 ADMIN: Thêm AdminService

  // -------------------------------------------------------------------
  // --- QUẢN LÝ TRẠNG THÁI NGƯỜI DÙNG ---
  // -------------------------------------------------------------------

  /// Stream để lắng nghe sự thay đổi trạng thái đăng nhập (đăng nhập/đăng xuất).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Lấy thông tin người dùng hiện tại.
  User? get currentUser => _auth.currentUser;

  // -------------------------------------------------------------------
  // --- CÁC PHƯƠNG THỨC XÁC THỰC ---
  // -------------------------------------------------------------------

  /// 1. Đăng ký tài khoản mới bằng Email, Mật khẩu và Tên hiển thị.
  /// 🔥 ADMIN: Auto-promote nếu email trong whitelist
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      // Tạo người dùng trong Firebase Authentication
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Cập nhật displayName trên FirebaseAuth để UI có thể đọc trực tiếp (nếu cần)
        try {
          await user.updateDisplayName(displayName);
          await user.reload();
        } catch (e) {
          print('Không thể cập nhật displayName trên Auth: $e');
        }

        // 🔥 ADMIN: Check whitelist để tự động promote
        final isWhitelisted = await _adminService.isInAdminWhitelist(email);
        final role = isWhitelisted ? 'admin' : 'user';

        // Sau khi tạo tài khoản thành công, tạo một bản ghi cho người dùng trong Firestore
        await _firestoreService.createUserDocument(user, displayName, role);
        
        if (isWhitelisted) {
          print('🎉 User $email được auto-promote lên admin (trong whitelist)');
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print("AuthService Lỗi: ${e.message}");
      rethrow; // Ném lỗi ra cho UI
    }
  }

  /// 2. Đăng nhập bằng Email và Mật khẩu.
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Đăng nhập người dùng bằng Firebase Authentication
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Lỗi đăng nhập: ${e.message}");
      return null; // Trả về null khi đăng nhập thất bại
    }
  }

  /// 3. Đăng xuất khỏi tài khoản hiện tại.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 4. Gửi email khôi phục mật khẩu.
  /// (HÀM MỚI THÊM VÀO)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Ném lỗi ra để UI có thể bắt và hiển thị
      print("Lỗi gửi email reset: ${e.message}");
      rethrow;
    }
  }
}
