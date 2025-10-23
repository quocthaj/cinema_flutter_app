// lib/data/models/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
  });

  // Hàm để chuyển đổi đối tượng UserModel thành một Map, sẵn sàng để ghi vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'favoriteMovies': [], // Khởi tạo mảng phim yêu thích là rỗng
    };
  }
}
