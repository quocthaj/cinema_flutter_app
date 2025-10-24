import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho lịch chiếu phim
/// Collection: showtimes
/// Mối quan hệ:
/// - movieId -> movies/{movieId}
/// - screenId -> screens/{screenId}
/// - theaterId -> theaters/{theaterId}
class Showtime {
  final String id;
  final String movieId; // Reference đến Movie
  final String screenId; // Reference đến Screen
  final String theaterId; // Reference đến Theater (để query nhanh hơn)
  final DateTime startTime; // Thời gian bắt đầu (ngày + giờ)
  final DateTime endTime; // Thời gian kết thúc
  final double basePrice; // Giá vé cơ bản
  final double vipPrice; // Giá vé VIP
  final int availableSeats; // Số ghế còn trống
  final List<String> bookedSeats; // Danh sách ghế đã đặt (ví dụ: ["A1", "A2"])
  final String status; // active | cancelled | completed

  Showtime({
    required this.id,
    required this.movieId,
    required this.screenId,
    required this.theaterId,
    required this.startTime,
    required this.endTime,
    required this.basePrice,
    required this.vipPrice,
    required this.availableSeats,
    required this.bookedSeats,
    required this.status,
  });

  /// Tạo Showtime từ Firestore DocumentSnapshot
  factory Showtime.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Showtime(
      id: doc.id,
      movieId: data['movieId'] ?? '',
      screenId: data['screenId'] ?? '',
      theaterId: data['theaterId'] ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      vipPrice: (data['vipPrice'] ?? 0).toDouble(),
      availableSeats: (data['availableSeats'] ?? 0).toInt(),
      bookedSeats: List<String>.from(data['bookedSeats'] ?? []),
      status: data['status'] ?? 'active',
    );
  }

  /// Chuyển đổi Showtime thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'screenId': screenId,
      'theaterId': theaterId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'basePrice': basePrice,
      'vipPrice': vipPrice,
      'availableSeats': availableSeats,
      'bookedSeats': bookedSeats,
      'status': status,
    };
  }

  /// Convert sang JSON (để debug hoặc API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'screenId': screenId,
      'theaterId': theaterId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'basePrice': basePrice,
      'vipPrice': vipPrice,
      'availableSeats': availableSeats,
      'bookedSeats': bookedSeats,
      'status': status,
    };
  }

  /// Copy với một số trường thay đổi (immutable pattern)
  Showtime copyWith({
    String? id,
    String? movieId,
    String? screenId,
    String? theaterId,
    DateTime? startTime,
    DateTime? endTime,
    double? basePrice,
    double? vipPrice,
    int? availableSeats,
    List<String>? bookedSeats,
    String? status,
  }) {
    return Showtime(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      screenId: screenId ?? this.screenId,
      theaterId: theaterId ?? this.theaterId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      basePrice: basePrice ?? this.basePrice,
      vipPrice: vipPrice ?? this.vipPrice,
      availableSeats: availableSeats ?? this.availableSeats,
      bookedSeats: bookedSeats ?? this.bookedSeats,
      status: status ?? this.status,
    );
  }

  /// Lấy ngày chiếu (format: dd/MM/yyyy)
  String getDate() {
    return '${startTime.day.toString().padLeft(2, '0')}/${startTime.month.toString().padLeft(2, '0')}/${startTime.year}';
  }

  /// Lấy giờ chiếu (format: HH:mm)
  String getTime() {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }
}
