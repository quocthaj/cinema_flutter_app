import 'booking_model.dart';
import 'movie.dart';
import 'showtime.dart';

/// Model Ticket để hiển thị vé đã đặt (UI Model)
/// Đây là model kết hợp từ Booking + Movie + Showtime
/// Không lưu trực tiếp vào Firestore, chỉ dùng để hiển thị
class Ticket {
  final String id;
  final Booking booking;
  final Movie movie;
  final Showtime showtime;
  final String theaterName;
  final String screenName;

  Ticket({
    required this.id,
    required this.booking,
    required this.movie,
    required this.showtime,
    required this.theaterName,
    required this.screenName,
  });

  /// Getters để dễ truy cập thông tin
  List<String> get seats => booking.selectedSeats;
  double get totalPrice => booking.totalPrice;
  String get status => booking.status;
  DateTime get bookingDate => booking.createdAt;
  String get seatsString => booking.seatsString;
  int get seatCount => booking.seatCount;
  
  /// Lấy thông tin lịch chiếu
  String get showDate => showtime.getDate();
  String get showTime => showtime.getTime();

  /// Kiểm tra vé còn hiệu lực không
  bool get isValid => 
      booking.status == 'confirmed' && 
      showtime.startTime.isAfter(DateTime.now());

  /// Kiểm tra đã qua ngày chiếu chưa
  bool get isPast => showtime.startTime.isBefore(DateTime.now());
}

