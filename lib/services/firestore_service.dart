import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/movie.dart'; // <-- Thay 'movie_app' nếu cần
import '/models/user_model.dart'; // <-- THÊM: Import UserModel

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- QUẢN LÝ NGƯỜI DÙNG ---

  /// Tạo document cho người dùng mới
  Future<void> createUserDocument(User user, [String? displayName]) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName ?? user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'favoriteMovies': [],
        'phoneNumber': null,
        'membershipLevel': 'Đồng',
        'points': 0,
      });
    }
  }

  /// Lấy thông tin chi tiết của người dùng từ Firestore
  Future<UserModel?> getUserDocument(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        print("Không tìm thấy user document với uid: $uid");
        return null;
      }
    } catch (e) {
      print("Lỗi khi lấy user document: $e");
      return null;
    }
  }

  /// Cập nhật thông tin người dùng trên Firestore (HÀM MỚI)
  /// dataToUpdate là một Map chứa các trường cần cập nhật, ví dụ:
  /// {'displayName': 'Tên Mới', 'phoneNumber': '0987654321'}
  Future<void> updateUserData(
      String uid, Map<String, dynamic> dataToUpdate) async {
    if (uid.isEmpty) return; // Không làm gì nếu uid rỗng
    try {
      // Sử dụng .update() để chỉ cập nhật các trường được cung cấp trong Map
      await _db.collection('users').doc(uid).update(dataToUpdate);
    } catch (e) {
      print("Lỗi khi cập nhật user data: $e");
      // Có thể ném lỗi ra để UI xử lý nếu cần
      rethrow;
    }
  }

  // --- QUẢN LÝ PHIM ---
  Stream<List<Movie>> getMoviesStream() {
    return _db.collection('movies').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList());
  }

  Future<Movie?> getMovieById(String movieId) async {
    if (movieId.isEmpty) return null;
    try {
      final doc = await _db.collection('movies').doc(movieId).get();
      if (doc.exists) {
        // Tạo đối tượng Movie từ dữ liệu Firestore
        // Cần đảm bảo Movie model có hàm fromFirestore
        return Movie.fromFirestore(doc);
      } else {
        print("Không tìm thấy phim với ID: $movieId");
        return null;
      }
    } catch (e) {
      print("Lỗi khi lấy phim theo ID: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> getUserBookingsStream(String userId) {
    if (userId.isEmpty) {
      // Trả về stream rỗng nếu chưa đăng nhập
      return const Stream.empty();
    }
    // Truy vấn collection 'bookings', lọc theo userId
    // Sắp xếp theo thời gian đặt vé mới nhất lên đầu
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingTime', descending: true)
        .snapshots();
  }

  // Hàm thêm booking mới (sẽ dùng khi làm chức năng đặt vé)
  Future<void> addBooking(Map<String, dynamic> bookingData) async {
    try {
      // Thêm bookingTime từ server
      bookingData['bookingTime'] = FieldValue.serverTimestamp();
      await _db.collection('bookings').add(bookingData);
    } catch (e) {
      print("Lỗi khi thêm booking: $e");
      rethrow;
    }
  }

  // (Các hàm CRUD Admin...)

  // --- QUẢN LÝ YÊU THÍCH ---
  // ...
}
