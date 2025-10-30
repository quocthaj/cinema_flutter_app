// lib/services/dynamic_pricing_service.dart

/// Service tính giá vé động dựa trên nhiều yếu tố
/// 
/// ✅ CÁC YẾU TỐ ẢNH HƯỞNG GIÁ:
/// 1. Loại ghế: Standard / VIP / Couple
/// 2. Loại phim: 2D / 3D / IMAX
/// 3. Khung giờ: Sáng / Chiều / Tối / Đêm
/// 4. Ngày: Weekday / Weekend / Holiday
/// 5. Loại phòng: Standard / VIP / IMAX
/// 6. Chương trình khuyến mãi (nếu có)
/// 
/// USAGE:
/// ```dart
/// final pricing = DynamicPricingService();
/// 
/// final price = pricing.calculatePrice(
///   seatType: SeatType.vip,
///   movieType: MovieType.threeD,
///   screenType: ScreenType.standard,
///   showtime: DateTime.parse('2025-10-29 19:00'),
/// );
/// 
/// print('Giá vé: ${price}đ');
/// ```
class DynamicPricingService {
  /// ========================================
  /// GIÁ CƠ BẢN (BASE PRICE)
  /// ========================================
  
  /// Giá cơ bản cho ghế Standard, phim 2D, ngày thường, giờ thường
  static const double basePriceStandard = 70000;
  
  /// ========================================
  /// HỆ SỐ ĐIỀU CHỈNH THEO LOẠI GHẾ
  /// ========================================
  
  static const Map<SeatType, double> seatTypeMultipliers = {
    SeatType.standard: 1.0,    // Không tăng
    SeatType.vip: 1.4,         // +40%
    SeatType.couple: 2.2,      // +120% (2 ghế)
  };
  
  /// ========================================
  /// HỆ SỐ ĐIỀU CHỈNH THEO LOẠI PHIM
  /// ========================================
  
  static const Map<MovieType, double> movieTypeMultipliers = {
    MovieType.twoD: 1.0,       // Không tăng
    MovieType.threeD: 1.3,     // +30%
    MovieType.imax: 1.7,       // +70%
    MovieType.imax3D: 2.0,     // +100%
  };
  
  /// ========================================
  /// HỆ SỐ ĐIỀU CHỈNH THEO LOẠI PHÒNG
  /// ========================================
  
  static const Map<ScreenType, double> screenTypeMultipliers = {
    ScreenType.standard: 1.0,  // Không tăng
    ScreenType.vip: 1.2,       // +20%
    ScreenType.imax: 1.5,      // +50%
    ScreenType.fourDX: 1.8,    // +80%
  };
  
  /// ========================================
  /// HỆ SỐ ĐIỀU CHỈNH THEO KHUNG GIỜ
  /// ========================================
  
  /// Giờ chiếu và hệ số điều chỉnh
  static const Map<TimeSlot, double> timeSlotMultipliers = {
    TimeSlot.earlyBird: 0.8,   // Sáng sớm (trước 12h): -20%
    TimeSlot.afternoon: 0.9,   // Chiều (12h-18h): -10%
    TimeSlot.primeTime: 1.2,   // Giờ vàng (18h-22h): +20%
    TimeSlot.lateNight: 0.9,   // Đêm muộn (sau 22h): -10%
  };
  
  /// ========================================
  /// HỆ SỐ ĐIỀU CHỈNH THEO NGÀY
  /// ========================================
  
  static const Map<DayType, double> dayTypeMultipliers = {
    DayType.weekday: 1.0,      // Thứ 2-5: Không tăng
    DayType.weekend: 1.3,      // Thứ 6-CN: +30%
    DayType.holiday: 1.5,      // Lễ tết: +50%
  };
  
  /// ========================================
  /// TÍNH GIÁ CHÍNH
  /// ========================================
  
  /// ✅ Tính giá vé cuối cùng
  /// 
  /// Formula: 
  /// Price = BasePrice 
  ///         × SeatTypeMultiplier 
  ///         × MovieTypeMultiplier 
  ///         × ScreenTypeMultiplier
  ///         × TimeSlotMultiplier 
  ///         × DayTypeMultiplier
  ///         - Discount (if any)
  double calculatePrice({
    required SeatType seatType,
    required MovieType movieType,
    required ScreenType screenType,
    required DateTime showtime,
    double discountPercent = 0,
    double? customBasePrice,
  }) {
    // 1. Base price
    final basePrice = customBasePrice ?? basePriceStandard;
    
    // 2. Các multipliers
    final seatMultiplier = seatTypeMultipliers[seatType] ?? 1.0;
    final movieMultiplier = movieTypeMultipliers[movieType] ?? 1.0;
    final screenMultiplier = screenTypeMultipliers[screenType] ?? 1.0;
    final timeMultiplier = _getTimeSlotMultiplier(showtime);
    final dayMultiplier = _getDayTypeMultiplier(showtime);
    
    // 3. Tính giá
    var price = basePrice 
                * seatMultiplier 
                * movieMultiplier 
                * screenMultiplier
                * timeMultiplier 
                * dayMultiplier;
    
    // 4. Áp dụng discount
    if (discountPercent > 0) {
      price = price * (1 - discountPercent / 100);
    }
    
    // 5. Làm tròn đến nghìn đồng
    return _roundToThousand(price);
  }
  
  /// ✅ Tính giá cho nhiều ghế
  /// 
  /// @return Tổng giá và breakdown từng loại ghế
  PriceBreakdown calculateTotalPrice({
    required Map<String, SeatType> seats, // {"A1": SeatType.standard, "A2": SeatType.vip}
    required MovieType movieType,
    required ScreenType screenType,
    required DateTime showtime,
    double discountPercent = 0,
  }) {
    final breakdown = <SeatType, SeatPriceInfo>{};
    var total = 0.0;
    
    for (var entry in seats.entries) {
      final seatId = entry.key;
      final seatType = entry.value;
      
      final price = calculatePrice(
        seatType: seatType,
        movieType: movieType,
        screenType: screenType,
        showtime: showtime,
        discountPercent: discountPercent,
      );
      
      // Cập nhật breakdown
      if (breakdown.containsKey(seatType)) {
        breakdown[seatType]!.count++;
        breakdown[seatType]!.totalPrice += price;
        breakdown[seatType]!.seatIds.add(seatId);
      } else {
        breakdown[seatType] = SeatPriceInfo(
          seatType: seatType,
          count: 1,
          pricePerSeat: price,
          totalPrice: price,
          seatIds: [seatId],
        );
      }
      
      total += price;
    }
    
    return PriceBreakdown(
      total: total,
      breakdown: breakdown,
      seatCount: seats.length,
    );
  }
  
  /// ========================================
  /// HELPER METHODS
  /// ========================================
  
  /// Xác định time slot dựa vào giờ chiếu
  TimeSlot _getTimeSlotFromHour(int hour) {
    if (hour < 12) return TimeSlot.earlyBird;
    if (hour < 18) return TimeSlot.afternoon;
    if (hour < 22) return TimeSlot.primeTime;
    return TimeSlot.lateNight;
  }
  
  /// Lấy multiplier theo time slot
  double _getTimeSlotMultiplier(DateTime showtime) {
    final timeSlot = _getTimeSlotFromHour(showtime.hour);
    return timeSlotMultipliers[timeSlot] ?? 1.0;
  }
  
  /// Xác định loại ngày
  DayType _getDayType(DateTime date) {
    // Check holiday trước (TODO: Có thể load từ config)
    if (_isHoliday(date)) {
      return DayType.holiday;
    }
    
    // Check weekend (Thứ 6, 7, CN)
    final weekday = date.weekday;
    if (weekday == DateTime.friday || 
        weekday == DateTime.saturday || 
        weekday == DateTime.sunday) {
      return DayType.weekend;
    }
    
    return DayType.weekday;
  }
  
  /// Lấy multiplier theo loại ngày
  double _getDayTypeMultiplier(DateTime date) {
    final dayType = _getDayType(date);
    return dayTypeMultipliers[dayType] ?? 1.0;
  }
  
  /// Kiểm tra ngày lễ (hardcoded cho demo, nên load từ config)
  bool _isHoliday(DateTime date) {
    // Danh sách ngày lễ Việt Nam 2025 (mm-dd)
    final holidays = [
      '01-01', // Tết Dương lịch
      '01-28', '01-29', '01-30', '01-31', '02-01', '02-02', '02-03', '02-04', // Tết Nguyên Đán
      '04-10', // Giỗ tổ Hùng Vương
      '04-30', // Giải phóng miền Nam
      '05-01', // Quốc tế Lao động
      '09-02', // Quốc khánh
    ];
    
    final dateStr = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return holidays.contains(dateStr);
  }
  
  /// Làm tròn đến nghìn đồng
  double _roundToThousand(double price) {
    return (price / 1000).round() * 1000.0;
  }
  
  /// ========================================
  /// CÔNG CỤ BỔ SUNG
  /// ========================================
  
  /// ✅ So sánh giá giữa các thời điểm
  /// 
  /// Giúp user chọn giờ rẻ nhất
  Map<DateTime, double> comparePrices({
    required List<DateTime> showtimes,
    required SeatType seatType,
    required MovieType movieType,
    required ScreenType screenType,
  }) {
    final prices = <DateTime, double>{};
    
    for (var showtime in showtimes) {
      prices[showtime] = calculatePrice(
        seatType: seatType,
        movieType: movieType,
        screenType: screenType,
        showtime: showtime,
      );
    }
    
    return prices;
  }
  
  /// ✅ Tìm suất chiếu rẻ nhất
  DateTime? findCheapestShowtime({
    required List<DateTime> showtimes,
    required SeatType seatType,
    required MovieType movieType,
    required ScreenType screenType,
  }) {
    if (showtimes.isEmpty) return null;
    
    final prices = comparePrices(
      showtimes: showtimes,
      seatType: seatType,
      movieType: movieType,
      screenType: screenType,
    );
    
    var cheapest = showtimes.first;
    var lowestPrice = prices[cheapest]!;
    
    for (var entry in prices.entries) {
      if (entry.value < lowestPrice) {
        cheapest = entry.key;
        lowestPrice = entry.value;
      }
    }
    
    return cheapest;
  }
  
  /// ✅ Lấy mô tả chi tiết về giá
  PriceExplanation explainPrice({
    required SeatType seatType,
    required MovieType movieType,
    required ScreenType screenType,
    required DateTime showtime,
  }) {
    final basePrice = basePriceStandard;
    final seatMultiplier = seatTypeMultipliers[seatType] ?? 1.0;
    final movieMultiplier = movieTypeMultipliers[movieType] ?? 1.0;
    final screenMultiplier = screenTypeMultipliers[screenType] ?? 1.0;
    final timeMultiplier = _getTimeSlotMultiplier(showtime);
    final dayMultiplier = _getDayTypeMultiplier(showtime);
    
    final finalPrice = calculatePrice(
      seatType: seatType,
      movieType: movieType,
      screenType: screenType,
      showtime: showtime,
    );
    
    return PriceExplanation(
      basePrice: basePrice,
      seatTypeMultiplier: seatMultiplier,
      movieTypeMultiplier: movieMultiplier,
      screenTypeMultiplier: screenMultiplier,
      timeSlotMultiplier: timeMultiplier,
      dayTypeMultiplier: dayMultiplier,
      finalPrice: finalPrice,
      seatType: seatType,
      movieType: movieType,
      screenType: screenType,
      timeSlot: _getTimeSlotFromHour(showtime.hour),
      dayType: _getDayType(showtime),
    );
  }
}

/// ========================================
/// ENUMS
/// ========================================

enum SeatType {
  standard,
  vip,
  couple,
}

enum MovieType {
  twoD,
  threeD,
  imax,
  imax3D,
}

enum ScreenType {
  standard,
  vip,
  imax,
  fourDX,
}

enum TimeSlot {
  earlyBird,   // < 12h
  afternoon,   // 12h - 18h
  primeTime,   // 18h - 22h
  lateNight,   // > 22h
}

enum DayType {
  weekday,
  weekend,
  holiday,
}

/// ========================================
/// MODELS
/// ========================================

/// Breakdown giá theo loại ghế
class PriceBreakdown {
  final double total;
  final Map<SeatType, SeatPriceInfo> breakdown;
  final int seatCount;
  
  PriceBreakdown({
    required this.total,
    required this.breakdown,
    required this.seatCount,
  });
  
  /// Format hiển thị
  String get formattedTotal {
    return '${total.toStringAsFixed(0)}đ';
  }
  
  /// Chi tiết từng loại
  String get detailText {
    final lines = <String>[];
    
    for (var entry in breakdown.entries) {
      final info = entry.value;
      lines.add('${info.seatType.displayName} (${info.count}): ${info.formattedTotal}');
    }
    
    return lines.join('\n');
  }
}

/// Thông tin giá của một loại ghế
class SeatPriceInfo {
  final SeatType seatType;
  int count;
  final double pricePerSeat;
  double totalPrice;
  final List<String> seatIds;
  
  SeatPriceInfo({
    required this.seatType,
    required this.count,
    required this.pricePerSeat,
    required this.totalPrice,
    required this.seatIds,
  });
  
  String get formattedTotal {
    return '${totalPrice.toStringAsFixed(0)}đ';
  }
  
  String get formattedPerSeat {
    return '${pricePerSeat.toStringAsFixed(0)}đ';
  }
}

/// Giải thích chi tiết cách tính giá
class PriceExplanation {
  final double basePrice;
  final double seatTypeMultiplier;
  final double movieTypeMultiplier;
  final double screenTypeMultiplier;
  final double timeSlotMultiplier;
  final double dayTypeMultiplier;
  final double finalPrice;
  final SeatType seatType;
  final MovieType movieType;
  final ScreenType screenType;
  final TimeSlot timeSlot;
  final DayType dayType;
  
  PriceExplanation({
    required this.basePrice,
    required this.seatTypeMultiplier,
    required this.movieTypeMultiplier,
    required this.screenTypeMultiplier,
    required this.timeSlotMultiplier,
    required this.dayTypeMultiplier,
    required this.finalPrice,
    required this.seatType,
    required this.movieType,
    required this.screenType,
    required this.timeSlot,
    required this.dayType,
  });
  
  /// Text giải thích chi tiết
  String get explanation {
    final buffer = StringBuffer();
    buffer.writeln('📊 CÁCH TÍNH GIÁ VÉ:');
    buffer.writeln('');
    buffer.writeln('Giá cơ bản: ${basePrice.toStringAsFixed(0)}đ');
    buffer.writeln('');
    buffer.writeln('× Loại ghế (${seatType.displayName}): ${_formatMultiplier(seatTypeMultiplier)}');
    buffer.writeln('× Loại phim (${movieType.displayName}): ${_formatMultiplier(movieTypeMultiplier)}');
    buffer.writeln('× Loại phòng (${screenType.displayName}): ${_formatMultiplier(screenTypeMultiplier)}');
    buffer.writeln('× Khung giờ (${timeSlot.displayName}): ${_formatMultiplier(timeSlotMultiplier)}');
    buffer.writeln('× Loại ngày (${dayType.displayName}): ${_formatMultiplier(dayTypeMultiplier)}');
    buffer.writeln('');
    buffer.writeln('= Giá cuối: ${finalPrice.toStringAsFixed(0)}đ');
    
    return buffer.toString();
  }
  
  String _formatMultiplier(double multiplier) {
    if (multiplier == 1.0) return '×1.0 (không thay đổi)';
    if (multiplier > 1.0) {
      final percent = ((multiplier - 1) * 100).toStringAsFixed(0);
      return '×$multiplier (+$percent%)';
    } else {
      final percent = ((1 - multiplier) * 100).toStringAsFixed(0);
      return '×$multiplier (-$percent%)';
    }
  }
}

/// ========================================
/// EXTENSIONS
/// ========================================

extension SeatTypeExtension on SeatType {
  String get displayName {
    switch (this) {
      case SeatType.standard:
        return 'Ghế thường';
      case SeatType.vip:
        return 'Ghế VIP';
      case SeatType.couple:
        return 'Ghế đôi';
    }
  }
}

extension MovieTypeExtension on MovieType {
  String get displayName {
    switch (this) {
      case MovieType.twoD:
        return '2D';
      case MovieType.threeD:
        return '3D';
      case MovieType.imax:
        return 'IMAX';
      case MovieType.imax3D:
        return 'IMAX 3D';
    }
  }
}

extension ScreenTypeExtension on ScreenType {
  String get displayName {
    switch (this) {
      case ScreenType.standard:
        return 'Phòng thường';
      case ScreenType.vip:
        return 'Phòng VIP';
      case ScreenType.imax:
        return 'IMAX';
      case ScreenType.fourDX:
        return '4DX';
    }
  }
}

extension TimeSlotExtension on TimeSlot {
  String get displayName {
    switch (this) {
      case TimeSlot.earlyBird:
        return 'Suất sáng';
      case TimeSlot.afternoon:
        return 'Suất chiều';
      case TimeSlot.primeTime:
        return 'Giờ vàng';
      case TimeSlot.lateNight:
        return 'Suất đêm';
    }
  }
}

extension DayTypeExtension on DayType {
  String get displayName {
    switch (this) {
      case DayType.weekday:
        return 'Ngày thường';
      case DayType.weekend:
        return 'Cuối tuần';
      case DayType.holiday:
        return 'Ngày lễ';
    }
  }
}
