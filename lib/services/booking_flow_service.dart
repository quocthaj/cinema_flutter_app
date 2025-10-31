// lib/services/booking_flow_service.dart

import '../models/booking_model.dart';
import '../models/payment_model.dart';
import 'seat_hold_service.dart';
import 'dynamic_pricing_service.dart';
import 'firestore_service.dart';

/// Orchestrator service điều phối toàn bộ booking flow
///
/// ✅ FLOW HOÀN CHỈNH:
/// 1. **Validate Showtime**: Kiểm tra suất chiếu còn khả dụng
/// 2. **Hold Seats**: Giữ ghế tạm thời (10 phút)
/// 3. **Calculate Price**: Tính giá động dựa trên nhiều yếu tố
/// 4. **Create Booking**: Tạo booking (transaction-based)
/// 5. **Process Payment**: Xử lý thanh toán
/// 6. **Confirm/Release**: Confirm nếu thành công, release nếu thất bại
///
/// USAGE:
/// ```dart
/// final flow = BookingFlowService();
///
/// // Start booking process
/// final result = await flow.startBookingProcess(
///   userId: user.uid,
///   showtimeId: 'showtime-1',
///   selectedSeats: ['A1', 'A2'],
///   seatTypes: {'A1': SeatType.standard, 'A2': SeatType.vip},
///   movieType: MovieType.twoD,
///   screenType: ScreenType.standard,
/// );
///
/// if (result.success) {
///   // Proceed to payment
///   final paymentResult = await flow.processPayment(
///     bookingId: result.bookingId!,
///     method: 'momo',
///     transactionId: 'MOMO-123',
///   );
/// }
/// ```
class BookingFlowService {
  final FirestoreService _firestoreService = FirestoreService();
  final SeatHoldService _seatHoldService = SeatHoldService();
  final DynamicPricingService _pricingService = DynamicPricingService();

  /// ✅ STEP 1: Validate showtime có available không
  Future<BookingValidationResult> validateShowtime(
    String showtimeId,
    List<String> requestedSeats,
  ) async {
    try {
      // 1. Kiểm tra showtime tồn tại
      final showtime = await _firestoreService.getShowtimeById(showtimeId);

      if (showtime == null) {
        return BookingValidationResult(
          isValid: false,
          error: 'Suất chiếu không tồn tại',
        );
      }

      // 2. Kiểm tra showtime đã qua chưa
      if (showtime.startTime.isBefore(DateTime.now())) {
        return BookingValidationResult(
          isValid: false,
          error: 'Suất chiếu đã qua',
        );
      }

      // 3. Kiểm tra showtime đã bị cancel chưa
      if (showtime.status != 'active') {
        return BookingValidationResult(
          isValid: false,
          error: 'Suất chiếu không còn hoạt động',
        );
      }

      // 4. Kiểm tra số ghế còn đủ không
      if (showtime.availableSeats < requestedSeats.length) {
        return BookingValidationResult(
          isValid: false,
          error: 'Không đủ ghế trống (còn ${showtime.availableSeats} ghế)',
        );
      }

      // 5. Kiểm tra các ghế cụ thể có bị booked/held không
      final bookedSeats = showtime.bookedSeats;
      final heldSeats = await _seatHoldService.getHeldSeats(showtimeId);

      final conflicts = <String>[];
      for (var seat in requestedSeats) {
        if (bookedSeats.contains(seat) || heldSeats.contains(seat)) {
          conflicts.add(seat);
        }
      }

      if (conflicts.isNotEmpty) {
        return BookingValidationResult(
          isValid: false,
          error: 'Ghế ${conflicts.join(", ")} đã được đặt hoặc đang giữ',
        );
      }

      return BookingValidationResult(
        isValid: true,
        showtime: showtime,
      );
    } catch (e) {
      return BookingValidationResult(
        isValid: false,
        error: 'Lỗi validate: $e',
      );
    }
  }

  /// ✅ STEP 2: Bắt đầu booking process (validate + hold seats)
  Future<BookingStartResult> startBookingProcess({
    required String userId,
    required String showtimeId,
    required List<String> selectedSeats,
    required Map<String, SeatType> seatTypes,
    required MovieType movieType,
    required ScreenType screenType,
    int holdDurationMinutes = 10,
  }) async {
    try {
      // 1. Validate showtime
      final validation = await validateShowtime(showtimeId, selectedSeats);

      if (!validation.isValid) {
        return BookingStartResult(
          success: false,
          error: validation.error,
        );
      }

      final showtime = validation.showtime!;

      // 2. Hold seats
      final holdId = await _seatHoldService.holdSeats(
        showtimeId: showtimeId,
        seats: selectedSeats,
        userId: userId,
        holdDurationMinutes: holdDurationMinutes,
      );

      if (holdId == null) {
        return BookingStartResult(
          success: false,
          error: 'Không thể giữ ghế. Vui lòng thử lại.',
        );
      }

      // 3. Calculate price
      final priceBreakdown = _pricingService.calculateTotalPrice(
        seats: seatTypes,
        movieType: movieType,
        screenType: screenType,
        showtime: showtime.startTime,
      );

      // 4. Create pending booking data (chưa lưu Firestore)
      final bookingData = {
        'userId': userId,
        'showtimeId': showtimeId,
        'movieId': showtime.movieId,
        'theaterId': showtime.theaterId,
        'screenId': showtime.screenId,
        'selectedSeats': selectedSeats,
        'seatTypes': seatTypes.map((k, v) => MapEntry(k, v.name)),
        'totalPrice': priceBreakdown.total,
        'priceBreakdown': priceBreakdown.toJson(),
        'status': 'pending',
        'holdId': holdId,
      };

      return BookingStartResult(
        success: true,
        holdId: holdId,
        totalPrice: priceBreakdown.total,
        priceBreakdown: priceBreakdown,
        bookingData: bookingData,
        expiresAt: DateTime.now().add(Duration(minutes: holdDurationMinutes)),
      );
    } catch (e) {
      return BookingStartResult(
        success: false,
        error: 'Lỗi: $e',
      );
    }
  }

  /// ✅ STEP 3: Confirm booking và tạo vào Firestore
  Future<BookingConfirmResult> confirmBooking({
    required Map<String, dynamic> bookingData,
    required String holdId,
  }) async {
    try {
      // 1. Verify hold còn active không
      final remainingSeconds =
          await _seatHoldService.getHoldRemainingSeconds(holdId);

      if (remainingSeconds <= 0) {
        return BookingConfirmResult(
          success: false,
          error: 'Hết thời gian giữ chỗ. Vui lòng chọn lại.',
        );
      }

      // 2. Create booking với transaction
      final booking = Booking(
        id: '', // Bạn có thể bỏ qua trường 'id' này nếu constructor của bạn
        // (trong booking_model.dart) không bắt buộc nó (ví dụ: `String? id`).
        // Nếu nó *bắt buộc*, hãy để id: '' như bạn đã làm.

        userId: bookingData['userId'],
        showtimeId: bookingData['showtimeId'],
        movieId: bookingData['movieId'],
        theaterId: bookingData['theaterId'],
        screenId: bookingData['screenId'],

        // --- SỬA Ở ĐÂY: THÊM CÁC TRƯỜNG ĐÃ SAO CHÉP (BẮT BUỘC) ---
        // (Bạn phải đảm bảo bookingData có các key này)
        movieTitle: bookingData['movieTitle'] as String,
        theaterName: bookingData['theaterName'] as String,
        screenName: bookingData['screenName']
            as String, // 'screenName' hoặc 'roomName' tùy bạn đặt
        // -----------------------------------------------------

        selectedSeats: List<String>.from(bookingData['selectedSeats']),
        seatTypes: Map<String, String>.from(bookingData['seatTypes']),
        totalPrice:
            (bookingData['totalPrice'] as num).toDouble(), // Ép kiểu an toàn
        status: 'pending',
        createdAt:
            DateTime.now(), // .toMap() sẽ chuyển nó thành Timestamp khi lưu
      );

      final bookingId = await _firestoreService.createBooking(booking);

      // 3. Confirm hold (không auto-release nữa)
      await _seatHoldService.confirmHold(holdId);

      return BookingConfirmResult(
        success: true,
        bookingId: bookingId,
      );
    } catch (e) {
      // Nếu lỗi → release hold
      await _seatHoldService.releaseHold(holdId, reason: 'booking_failed');

      return BookingConfirmResult(
        success: false,
        error: 'Lỗi tạo booking: $e',
      );
    }
  }

  /// ✅ STEP 4: Process payment
  Future<PaymentResult> processPayment({
    required String bookingId,
    required String method,
    String? transactionId,
  }) async {
    try {
      // 1. Get booking
      final booking = await _firestoreService.getBookingById(bookingId);

      if (booking == null) {
        return PaymentResult(
          success: false,
          error: 'Booking không tồn tại',
        );
      }

      // 2. Check booking status
      if (booking.status != 'pending') {
        return PaymentResult(
          success: false,
          error: 'Booking không ở trạng thái pending',
        );
      }

      // 3. Create payment record
      final payment = Payment(
        id: '',
        bookingId: bookingId,
        userId: booking.userId,
        amount: booking.totalPrice,
        method: method,
        status: 'pending',
        createdAt: DateTime.now(),
        transactionId: transactionId,
      );

      final paymentId = await _firestoreService.createPayment(payment);

      // 4. Simulate payment processing (trong thực tế gọi API gateway)
      await Future.delayed(Duration(seconds: 1));

      // 5. Update payment status to success
      await _firestoreService.updatePaymentStatus(
        paymentId,
        'success',
        transactionId:
            transactionId ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      );

      // 6. Update booking status to confirmed
      await _firestoreService.updateBookingStatus(bookingId, 'confirmed');

      return PaymentResult(
        success: true,
        paymentId: paymentId,
        transactionId: transactionId,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: 'Lỗi thanh toán: $e',
      );
    }
  }

  /// ✅ COMPLETE FLOW: Start → Confirm → Payment (all-in-one)
  ///
  /// Dùng khi muốn xử lý toàn bộ flow trong 1 lần gọi
  Future<CompleteBookingResult> completeBookingFlow({
    required String userId,
    required String showtimeId,
    required List<String> selectedSeats,
    required Map<String, SeatType> seatTypes,
    required MovieType movieType,
    required ScreenType screenType,
    required String paymentMethod,
    String? transactionId,
  }) async {
    try {
      // Step 1: Start
      final startResult = await startBookingProcess(
        userId: userId,
        showtimeId: showtimeId,
        selectedSeats: selectedSeats,
        seatTypes: seatTypes,
        movieType: movieType,
        screenType: screenType,
      );

      if (!startResult.success) {
        return CompleteBookingResult(
          success: false,
          error: startResult.error,
          step: 'start',
        );
      }

      // Step 2: Confirm
      final confirmResult = await confirmBooking(
        bookingData: startResult.bookingData!,
        holdId: startResult.holdId!,
      );

      if (!confirmResult.success) {
        return CompleteBookingResult(
          success: false,
          error: confirmResult.error,
          step: 'confirm',
        );
      }

      // Step 3: Payment
      final paymentResult = await processPayment(
        bookingId: confirmResult.bookingId!,
        method: paymentMethod,
        transactionId: transactionId,
      );

      if (!paymentResult.success) {
        // Rollback: Cancel booking
        await _firestoreService.cancelBooking(confirmResult.bookingId!);

        return CompleteBookingResult(
          success: false,
          error: paymentResult.error,
          step: 'payment',
          bookingId: confirmResult.bookingId,
        );
      }

      return CompleteBookingResult(
        success: true,
        bookingId: confirmResult.bookingId,
        paymentId: paymentResult.paymentId,
        totalPrice: startResult.totalPrice,
        step: 'completed',
      );
    } catch (e) {
      return CompleteBookingResult(
        success: false,
        error: 'Lỗi: $e',
        step: 'unknown',
      );
    }
  }

  /// ✅ Cancel booking flow
  Future<CancelBookingResult> cancelBooking(String bookingId) async {
    try {
      await _firestoreService.cancelBooking(bookingId);

      return CancelBookingResult(
        success: true,
      );
    } catch (e) {
      return CancelBookingResult(
        success: false,
        error: 'Lỗi hủy booking: $e',
      );
    }
  }

  /// ✅ Extend hold time (gia hạn thời gian giữ chỗ)
  Future<bool> extendHoldTime(String holdId, int additionalMinutes) async {
    return await _seatHoldService.extendHold(holdId, additionalMinutes);
  }

  /// ✅ Release hold (người dùng cancel trước khi booking)
  Future<bool> releaseHold(String holdId) async {
    return await _seatHoldService.releaseHold(holdId, reason: 'user_cancel');
  }
}

/// ========================================
/// RESULT MODELS
/// ========================================

class BookingValidationResult {
  final bool isValid;
  final String? error;
  final dynamic showtime;

  BookingValidationResult({
    required this.isValid,
    this.error,
    this.showtime,
  });
}

class BookingStartResult {
  final bool success;
  final String? error;
  final String? holdId;
  final double? totalPrice;
  final PriceBreakdown? priceBreakdown;
  final Map<String, dynamic>? bookingData;
  final DateTime? expiresAt;

  BookingStartResult({
    required this.success,
    this.error,
    this.holdId,
    this.totalPrice,
    this.priceBreakdown,
    this.bookingData,
    this.expiresAt,
  });
}

class BookingConfirmResult {
  final bool success;
  final String? error;
  final String? bookingId;

  BookingConfirmResult({
    required this.success,
    this.error,
    this.bookingId,
  });
}

class PaymentResult {
  final bool success;
  final String? error;
  final String? paymentId;
  final String? transactionId;

  PaymentResult({
    required this.success,
    this.error,
    this.paymentId,
    this.transactionId,
  });
}

class CompleteBookingResult {
  final bool success;
  final String? error;
  final String? bookingId;
  final String? paymentId;
  final double? totalPrice;
  final String step;

  CompleteBookingResult({
    required this.success,
    this.error,
    this.bookingId,
    this.paymentId,
    this.totalPrice,
    required this.step,
  });
}

class CancelBookingResult {
  final bool success;
  final String? error;

  CancelBookingResult({
    required this.success,
    this.error,
  });
}

/// Extension for PriceBreakdown to support JSON
extension PriceBreakdownJson on PriceBreakdown {
  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'seatCount': seatCount,
      'breakdown': breakdown.map((k, v) => MapEntry(
            k.name,
            {
              'count': v.count,
              'pricePerSeat': v.pricePerSeat,
              'totalPrice': v.totalPrice,
              'seatIds': v.seatIds,
            },
          )),
    };
  }
}
