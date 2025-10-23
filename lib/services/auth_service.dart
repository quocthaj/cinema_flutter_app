import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart'; // <-- Thay 'movie_app' bằng tên dự án của bạn

class AuthService {
  // Khởi tạo các dịch vụ Firebase cần thiết
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

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
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    // SỬA ĐỔI QUAN TRỌNG:
    // Chúng ta bắt lỗi và 'rethrow' (ném lại) để cho RegisterScreen có thể
    // bắt được và hiển thị thông báo lỗi chính xác.
    try {
      // Tạo người dùng trong Firebase Authentication
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Sau khi tạo tài khoản thành công, tạo một bản ghi cho người dùng trong Firestore
        await _firestoreService.createUserDocument(user, displayName);
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
