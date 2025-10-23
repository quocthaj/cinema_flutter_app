import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  // --- THÊM CÁC TRƯỜNG MỚI ---
  final String? phoneNumber;
  final String? membershipLevel;
  final int? points; // Điểm thường là số nguyên

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    // --- THÊM VÀO CONSTRUCTOR ---
    this.phoneNumber,
    this.membershipLevel,
    this.points,
  });

  // Hàm để chuyển đổi đối tượng UserModel thành Map để ghi vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'favoriteMovies': [], // Giữ nguyên
      // --- THÊM CÁC TRƯỜNG MỚI (có thể là null ban đầu) ---
      'phoneNumber': phoneNumber,
      'membershipLevel': membershipLevel ?? 'Đồng', // Giá trị mặc định
      'points': points ?? 0, // Giá trị mặc định
    };
  }

  // Factory constructor để tạo UserModel từ Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Xử lý createdAt (có thể là Timestamp hoặc String)
    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdAt =
          DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now();
    } else {
      createdAt = DateTime.now(); // Fallback
    }

    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      createdAt: createdAt,
      // --- LẤY CÁC TRƯỜNG MỚI TỪ FIRESTORE ---
      phoneNumber: data['phoneNumber'],
      membershipLevel: data['membershipLevel'],
      points: data['points'] is int
          ? data['points']
          : (data['points']?.toInt() ?? 0), // Đảm bảo points là int
    );
  }
}
