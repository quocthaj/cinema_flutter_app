import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final DateTime createdAt;
  // --- THÊM CÁC TRƯỜNG MỚI ---
  final String? phoneNumber;
  final String? membershipLevel;
  final int? points; // Điểm thường là số nguyên
  final String role; // 🔥 ADMIN: 'admin' hoặc 'user'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.createdAt,
    // --- THÊM VÀO CONSTRUCTOR ---
    this.phoneNumber,
    this.membershipLevel,
    this.points,
    this.role = 'user', // 🔥 ADMIN: Mặc định là user
  });
  
  /// 🔥 ADMIN: Helper getter
  bool get isAdmin => role == 'admin';

  // Getter để tương thích với code cũ sử dụng displayName
  String get displayName => name;

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
      id: doc.id,
      name: data['displayName'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatarUrl: data['photoUrl'] ?? data['avatarUrl'] ?? '',
      createdAt: createdAt,
      // --- LẤY CÁC TRƯỜNG MỚI TỪ FIRESTORE ---
      phoneNumber: data['phoneNumber'],
      membershipLevel: data['membershipLevel'],
      points: data['points'] is int
          ? data['points']
          : (data['points']?.toInt() ?? 0), // Đảm bảo points là int
      role: data['role'] ?? 'user', // 🔥 ADMIN: Lấy role từ Firestore
    );
  }

  /// 🔥 ADMIN: Factory constructor từ Map (cho queries)
  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdAt = DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return UserModel(
      id: id,
      name: data['displayName'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatarUrl: data['photoUrl'] ?? data['avatarUrl'] ?? '',
      createdAt: createdAt,
      phoneNumber: data['phoneNumber'],
      membershipLevel: data['membershipLevel'],
      points: data['points'] is int ? data['points'] : (data['points']?.toInt() ?? 0),
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'displayName': name, // 🔥 ADMIN: Đảm bảo compatibility
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'photoUrl': avatarUrl, // 🔥 ADMIN: Đảm bảo compatibility
      'createdAt': createdAt,
      'phoneNumber': phoneNumber,
      'membershipLevel': membershipLevel,
      'points': points,
      'role': role, // 🔥 ADMIN: Thêm role vào map
    };
  }
}

