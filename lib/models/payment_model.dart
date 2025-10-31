// lib/models/payment_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Cần cho IconData
import 'package:intl/intl.dart';

/// Enum (liệt kê) các trạng thái thanh toán nội bộ
/// Dùng cho logic của UI (ví dụ: PaymentService)
enum PaymentStatus {
  pending, // Đang chờ tạo
  processing, // Đã gửi đi (đang chờ callback)
  success, // Thành công
  failed, // Thất bại
  canceled, // Bị hủy
  unknown, // Không xác định
}

/// Model cho lớp Payment (Lưu trên Firestore 'payments')
/// Lớp này đại diện cho cấu trúc dữ liệu trên Firestore.
class Payment {
  final String id;
  final String bookingId; // Reference đến Booking
  final String userId; // Reference đến User
  final double amount; // Số tiền thanh toán
  final String method; // momo | vnpay | zalopay | credit_card | cash

  // Dùng String cho status để khớp với Firestore
  // 'pending', 'success', 'failed', 'cancelled', 'refunded'
  final String status;

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
      status: data['status'] ?? 'pending', // Lấy status dạng String
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
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'transactionId': transactionId,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  // --- Các Getters hữu ích ---

  /// Kiểm tra thanh toán có thành công không
  bool get isSuccess => status == 'success';

  /// Kiểm tra thanh toán có thất bại không
  bool get isFailed => status == 'failed' || status == 'cancelled';

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
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }
}

/// Model Cấu hình Ví (Dùng cho UI `payment_selection_screen.dart`)
class EWalletConfig {
  final String gatewayId; // 'momo', 'zalopay', 'vnpay'
  final String name; // 'Ví MoMo', 'ZaloPay'
  final String logoAssetPath; // 'assets/images/momo_logo.png'
  final IconData? icon; // (Tùy chọn)

  EWalletConfig({
    required this.gatewayId,
    required this.name,
    required this.logoAssetPath,
    this.icon,
  });
}

/// Model Biên lai (Dùng cho UI `receipt_screen.dart`)
class TransactionReceipt {
  final String transactionId; // ID từ collection 'payments'
  final String movieTitle;
  final String theaterName;
  final String roomName;
  final DateTime showtime;
  final List<String> seats;
  final double amountPaid;
  final String paymentMethod;
  final DateTime paymentTime;
  final String status;

  TransactionReceipt({
    required this.transactionId,
    required this.movieTitle,
    required this.theaterName,
    required this.roomName,
    required this.showtime,
    required this.seats,
    required this.amountPaid,
    required this.paymentMethod,
    required this.paymentTime,
    required this.status,
  });
}
