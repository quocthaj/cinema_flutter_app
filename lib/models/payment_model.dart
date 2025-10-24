import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho thanh toán
/// Collection: payments
/// Mối quan hệ:
/// - bookingId -> bookings/{bookingId}
/// - userId -> users/{userId}
class Payment {
  final String id;
  final String bookingId; // Reference đến Booking
  final String userId; // Reference đến User
  final double amount; // Số tiền thanh toán
  final String method; // momo | vnpay | zalopay | credit_card | cash
  final String status; // pending | success | failed | refunded
  final DateTime createdAt; // Thời gian tạo
  final DateTime? completedAt; // Thời gian hoàn thành
  final String? transactionId; // Mã giao dịch từ payment gateway
  final String? errorMessage; // Thông báo lỗi (nếu có)
  final Map<String, dynamic>? metadata; // Thông tin thêm từ payment gateway

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.errorMessage,
    this.metadata,
  });

  /// Tạo Payment từ Firestore DocumentSnapshot
  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      method: data['method'] ?? 'cash',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      transactionId: data['transactionId'],
      errorMessage: data['errorMessage'],
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata']) 
          : null,
    );
  }

  /// Chuyển đổi Payment thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'transactionId': transactionId,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionId': transactionId,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  /// Copy với một số trường thay đổi
  Payment copyWith({
    String? id,
    String? bookingId,
    String? userId,
    double? amount,
    String? method,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? transactionId,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      transactionId: transactionId ?? this.transactionId,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Kiểm tra thanh toán có thành công không
  bool get isSuccess => status == 'success';

  /// Kiểm tra thanh toán có thất bại không
  bool get isFailed => status == 'failed';

  /// Kiểm tra thanh toán đang chờ xử lý
  bool get isPending => status == 'pending';

  /// Lấy tên phương thức thanh toán (hiển thị)
  String get methodName {
    switch (method) {
      case 'momo':
        return 'MoMo';
      case 'vnpay':
        return 'VNPay';
      case 'zalopay':
        return 'ZaloPay';
      case 'credit_card':
        return 'Thẻ tín dụng';
      case 'cash':
        return 'Tiền mặt';
      default:
        return 'Khác';
    }
  }

  /// Format số tiền (ví dụ: 150.000đ)
  String get formattedAmount {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    )}đ';
  }
}
