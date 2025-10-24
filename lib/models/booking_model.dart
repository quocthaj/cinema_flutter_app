import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho đặt vé
/// Collection: bookings
/// Mối quan hệ:
/// - userId -> users/{userId}
/// - showtimeId -> showtimes/{showtimeId}
/// - movieId -> movies/{movieId} (duplicate để query nhanh)
class Booking {
  final String id;
  final String userId; // Reference đến User
  final String showtimeId; // Reference đến Showtime
  final String movieId; // Duplicate từ showtime (để query nhanh)
  final String theaterId; // Duplicate từ showtime
  final String screenId; // Duplicate từ showtime
  final List<String> selectedSeats; // Danh sách ghế đã chọn (ví dụ: ["A1", "A2"])
  final Map<String, String> seatTypes; // Map ghế và loại ghế {"A1": "standard", "A2": "vip"}
  final double totalPrice; // Tổng tiền
  final String status; // pending | confirmed | cancelled | completed
  final DateTime createdAt; // Thời gian tạo booking
  final DateTime? updatedAt; // Thời gian cập nhật
  final String? paymentId; // Reference đến Payment (sau khi thanh toán)
  final Map<String, dynamic>? metadata; // Thông tin thêm (promo code, discount, etc.)

  Booking({
    required this.id,
    required this.userId,
    required this.showtimeId,
    required this.movieId,
    required this.theaterId,
    required this.screenId,
    required this.selectedSeats,
    required this.seatTypes,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.paymentId,
    this.metadata,
  });

  /// Tạo Booking từ Firestore DocumentSnapshot
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      showtimeId: data['showtimeId'] ?? '',
      movieId: data['movieId'] ?? '',
      theaterId: data['theaterId'] ?? '',
      screenId: data['screenId'] ?? '',
      selectedSeats: List<String>.from(data['selectedSeats'] ?? []),
      seatTypes: Map<String, String>.from(data['seatTypes'] ?? {}),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      paymentId: data['paymentId'],
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata']) 
          : null,
    );
  }

  /// Chuyển đổi Booking thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'showtimeId': showtimeId,
      'movieId': movieId,
      'theaterId': theaterId,
      'screenId': screenId,
      'selectedSeats': selectedSeats,
      'seatTypes': seatTypes,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'paymentId': paymentId,
      'metadata': metadata,
    };
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'showtimeId': showtimeId,
      'movieId': movieId,
      'theaterId': theaterId,
      'screenId': screenId,
      'selectedSeats': selectedSeats,
      'seatTypes': seatTypes,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'paymentId': paymentId,
      'metadata': metadata,
    };
  }

  /// Copy với một số trường thay đổi
  Booking copyWith({
    String? id,
    String? userId,
    String? showtimeId,
    String? movieId,
    String? theaterId,
    String? screenId,
    List<String>? selectedSeats,
    Map<String, String>? seatTypes,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentId,
    Map<String, dynamic>? metadata,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      showtimeId: showtimeId ?? this.showtimeId,
      movieId: movieId ?? this.movieId,
      theaterId: theaterId ?? this.theaterId,
      screenId: screenId ?? this.screenId,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      seatTypes: seatTypes ?? this.seatTypes,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentId: paymentId ?? this.paymentId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Kiểm tra booking có hợp lệ không
  bool isValid() {
    return selectedSeats.isNotEmpty && totalPrice > 0;
  }

  /// Kiểm tra booking có thể hủy không
  bool canCancel() {
    return status == 'pending' || status == 'confirmed';
  }

  /// Lấy số lượng ghế đã đặt
  int get seatCount => selectedSeats.length;

  /// Format danh sách ghế (ví dụ: "A1, A2, A3")
  String get seatsString => selectedSeats.join(', ');
}
