import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho đặt vé
/// Collection: bookings
class Booking {
  final String id;
  final String userId;
  final String showtimeId;
  final String movieId;
  final String theaterId;
  final String screenId;

  // --- THÊM CÁC TRƯỜNG SAO CHÉP (DENORMALIZED) ĐỂ HIỂN THỊ BIÊN LAI ---
  final String movieTitle; // Tên phim
  final String theaterName; // Tên rạp
  final String screenName; // Tên phòng
  // -------------------------------------------------------------

  final List<String>
      selectedSeats; // Danh sách ghế đã chọn (ví dụ: ["A1", "A2"])
  final Map<String, String>
      seatTypes; // Map ghế và loại ghế {"A1": "standard", "A2": "vip"}
  final double totalPrice; // Tổng tiền
  final String status; // pending | confirmed | cancelled | completed
  final DateTime createdAt; // Thời gian tạo booking
  final DateTime? updatedAt; // Thời gian cập nhật
  final String? paymentId; // Reference đến Payment (sau khi thanh toán)
  final Map<String, dynamic>? metadata;

  Booking({
    required this.id,
    required this.userId,
    required this.showtimeId,
    required this.movieId,
    required this.theaterId,
    required this.screenId,

    // Thêm vào constructor
    required this.movieTitle,
    required this.theaterName,
    required this.screenName,
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

      // Lấy các trường đã sao chép
      movieTitle: data['movieTitle'] ?? 'Phim không rõ',
      theaterName: data['theaterName'] ?? 'Rạp không rõ',
      screenName: data['screenName'] ?? 'Phòng không rõ',

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

      // Thêm các trường sao chép khi lưu
      'movieTitle': movieTitle,
      'theaterName': theaterName,
      'screenName': screenName,

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
