// lib/core/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/movie.dart';
// Các import khác...

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- PHẦN QUẢN LÝ PHIM ---
  Stream<List<Movie>> getMoviesStream() {
    return _db
        .collection('movies')
        .snapshots() // Lắng nghe sự thay đổi
        .map((snapshot) => snapshot.docs
            .map((doc) => Movie.fromFirestore(
                doc)) // Chuyển đổi mỗi doc thành Movie object
            .toList());
  }

  // --- PHẦN QUẢN LÝ NGƯỜI DÙNG (MỚI) ---

  /// Tạo một document mới cho người dùng trong collection 'users'
  /// Sử dụng `SetOptions(merge: true)` để không ghi đè dữ liệu nếu người dùng đăng nhập lại
  Future<void> createUserDocument(User user, [String? displayName]) async {
    final userRef = _db.collection('users').doc(user.uid);

    // Kiểm tra xem document đã tồn tại chưa
    final doc = await userRef.get();
    if (!doc.exists) {
      // Chỉ tạo document nếu nó chưa tồn tại
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName ??
            user.displayName, // Lấy tên từ Google hoặc từ form đăng ký
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(), // Dùng timestamp của server
        'favoriteMovies': [], // Khởi tạo mảng phim yêu thích
      });
    }
  }
}
