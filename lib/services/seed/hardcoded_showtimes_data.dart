// lib/services/seed/hardcoded_showtimes_data.dart

/// ✅ REFACTORED: Real showtime schedules with DYNAMIC PRICING
/// 
/// LOGIC PHÂN BỔ SUẤT CHIẾU:
/// - Mỗi rạp có 4-5 phòng chiếu
/// - Mỗi phòng: 6 khung giờ/ngày (09:00, 11:30, 14:00, 16:30, 19:00, 21:30)
/// - Mỗi phim ~120 phút + 15 phút buffer = KHÔNG TRÙNG GIỜ
/// - 11 rạp × 4.5 phòng TB × 6 suất = ~297 suất/ngày
/// 
/// DYNAMIC PRICING (6 yếu tố):
/// 1. Screen type: Standard(1.0×) | VIP(1.2×) | IMAX(1.5×)
/// 2. Movie type: 2D(1.0×) | 3D(1.3×)
/// 3. Time of day: Morning(0.8×) | Lunch(0.9×) | Afternoon(1.0×) | Evening(1.2×) | Night(1.1×)
/// 4. Day of week: Weekday(1.0×) | Weekend(1.15×)
/// 5. Seat type: Standard(1.0×) | VIP(1.5×)
/// 6. Base price: 60,000 VNĐ
/// 
/// PHÂN BỔ PHIM:
/// - 8 phim đang chiếu được ưu tiên
/// - Mỗi phim chiếu ở nhiều rạp khác nhau
class HardcodedShowtimesData {
  
  /// ============================================
  /// BASE PRICES (VNĐ)
  /// ============================================
  static const double BASE_PRICE = 60000;
  
  /// ============================================
  /// MOVIE CONFIGURATIONS
  /// ============================================
  
  /// 8 phim đang chiếu (externalId) - ĐÚNG TỪ hardcoded_movies_data.dart
  static const nowShowingMovies = [
    'cuc-vang-cua-ngoai',      // 2D, Hài
    'nha-ma-xo',               // 2D, Kinh dị
    'tay-anh-giu-mot-vi-sao',  // 2D, Tình cảm
    'tee-yod-3',               // 2D, Kinh dị
    'tu-chien-tren-khong',     // 3D, Hành động
    'tron-ares',               // 3D/IMAX, Sci-fi
    'van-may',                 // 2D, Hài
    'to-quoc-trong-tim',       // 2D, Chiến tranh
  ];
  
  /// Movie durations (minutes)
  static const Map<String, int> movieDurations = {
    'cuc-vang-cua-ngoai': 110,
    'nha-ma-xo': 103,
    'tay-anh-giu-mot-vi-sao': 105,
    'tee-yod-3': 111,
    'tu-chien-tren-khong': 118,
    'tron-ares': 121,
    'van-may': 108,
    'to-quoc-trong-tim': 115,
  };
  
  /// Movie types (for pricing)
  static const Map<String, String> movieTypes = {
    'cuc-vang-cua-ngoai': '2d',
    'nha-ma-xo': '2d',
    'tay-anh-giu-mot-vi-sao': '2d',
    'tee-yod-3': '2d',
    'tu-chien-tren-khong': '3d',
    'tron-ares': '3d', // IMAX-capable
    'van-may': '2d',
    'to-quoc-trong-tim': '2d',
  };

  /// ============================================
  /// TIME SLOTS (không trùng lặp)
  /// ============================================
  
  /// Các khung giờ chiếu chuẩn
  /// Giả định mỗi phim ~120 phút + 15 phút buffer = 2h15
  static const timeSlots = [
    '09:00', // Sáng sớm
    '11:30', // Trưa
    '14:00', // Chiều
    '16:30', // Chiều muộn
    '19:00', // Tối (giờ vàng) ⭐
    '21:30', // Tối muộn
  ];

  /// ============================================
  /// DYNAMIC PRICING CALCULATOR
  /// ============================================
  
  /// Calculate dynamic price based on multiple factors
  static double calculatePrice({
    required String screenType,      // 'standard' | 'vip' | 'imax'
    required String movieType,       // '2d' | '3d'
    required String time,            // 'HH:mm'
    required bool isWeekend,         // true for Sat/Sun
    bool isVipSeat = false,          // VIP seat surcharge
  }) {
    double price = BASE_PRICE;
    
    // 1️⃣ Screen type multiplier
    if (screenType == 'imax') {
      price *= 1.5; // IMAX +50%
    } else if (screenType == 'vip') {
      price *= 1.2; // VIP room +20%
    }
    
    // 2️⃣ Movie type multiplier
    if (movieType == '3d') {
      price *= 1.3; // 3D +30%
    }
    
    // 3️⃣ Time of day multiplier
    final hour = int.parse(time.split(':')[0]);
    if (hour >= 6 && hour < 12) {
      price *= 0.8; // Morning -20%
    } else if (hour >= 12 && hour < 14) {
      price *= 0.9; // Lunch -10%
    } else if (hour >= 18 && hour < 22) {
      price *= 1.2; // Evening +20% ⭐ Giờ vàng
    } else if (hour >= 22 || hour < 6) {
      price *= 1.1; // Night +10%
    }
    // else: Afternoon (14-18) = 1.0× (no change)
    
    // 4️⃣ Day of week multiplier
    if (isWeekend) {
      price *= 1.15; // Weekend +15%
    }
    
    // 5️⃣ VIP seat surcharge
    if (isVipSeat) {
      price *= 1.5; // VIP seat +50%
    }
    
    // Round to nearest 1,000
    return (price / 1000).round() * 1000.0;
  }

  /// ============================================
  /// SHOWTIME TEMPLATE CREATOR
  /// ============================================
  
  /// Tạo 1 showtime template (chưa có date, chỉ có time)
  /// Sẽ được expand thành nhiều showtimes khi seed (7 ngày)
  static Map<String, dynamic> createShowtime({
    required String movieExternalId,
    required String theaterExternalId,
    required int screenNumber,        // 1-5
    required String screenType,       // 'standard' | 'vip' | 'imax'
    required String time,             // 'HH:mm'
    bool isWeekend = false,           // Sẽ được set khi seed
  }) {
    final movieType = movieTypes[movieExternalId] ?? '2d';
    
    // Calculate base price (for standard seat)
    final basePrice = calculatePrice(
      screenType: screenType,
      movieType: movieType,
      time: time,
      isWeekend: isWeekend,
      isVipSeat: false,
    );
    
    // Calculate VIP seat price
    final vipPrice = calculatePrice(
      screenType: screenType,
      movieType: movieType,
      time: time,
      isWeekend: isWeekend,
      isVipSeat: true,
    );
    
    return {
      'movieExternalId': movieExternalId,
      'theaterExternalId': theaterExternalId,
      'screenExternalId': '$theaterExternalId-screen-$screenNumber',
      'screenType': screenType,
      'time': time,
      'basePrice': basePrice,
      'vipPrice': vipPrice,
      'duration': movieDurations[movieExternalId] ?? 120,
    };
  }

  /// ✅ NEW: Helper để tạo showtimes cho 1 rạp với nhiều phim
  /// STRATEGY: Mỗi phim xuất hiện ở NHIỀU PHÒNG KHÁC NHAU, mỗi giờ 1 phòng khác nhau
  /// Ví dụ: Tron Ares → 09:00 Phòng 1, 11:30 Phòng 3, 14:00 Phòng 5, 16:30 Phòng 2, 19:00 Phòng 4...
  static List<Map<String, dynamic>> generateTheaterShowtimes({
    required String theaterExternalId,
    required List<String> movieIds,
    required int standardScreenCount,  // Số phòng Standard
    required int vipScreenCount,       // Số phòng VIP
    required int imaxScreenCount,      // Số phòng IMAX
  }) {
    final List<Map<String, dynamic>> showtimes = [];
    
    // Tạo danh sách các phòng với loại
    final List<Map<String, dynamic>> screens = [];
    
    // Add Standard screens
    for (int i = 1; i <= standardScreenCount; i++) {
      screens.add({'number': i, 'type': 'standard'});
    }
    
    // Add VIP screens
    for (int i = 0; i < vipScreenCount; i++) {
      screens.add({'number': standardScreenCount + i + 1, 'type': 'vip'});
    }
    
    // Add IMAX screens
    for (int i = 0; i < imaxScreenCount; i++) {
      screens.add({'number': standardScreenCount + vipScreenCount + i + 1, 'type': 'imax'});
    }
    
    int movieIndex = 0;
    int timeIndex = 0;
    
    // Với mỗi khung giờ chiếu
    for (var time in timeSlots) {
      // Xáo trộn thứ tự phim cho mỗi giờ chiếu khác nhau
      // Offset phim theo giờ chiếu để tạo sự đa dạng
      int offsetMovieIndex = movieIndex + timeIndex;
      
      // Với mỗi phòng chiếu
      for (var screen in screens) {
        final movieId = movieIds[offsetMovieIndex % movieIds.length];
        
        showtimes.add(createShowtime(
          movieExternalId: movieId,
          theaterExternalId: theaterExternalId,
          screenNumber: screen['number'] as int,
          screenType: screen['type'] as String,
          time: time,
        ));
        
        // Chuyển sang phim tiếp theo
        offsetMovieIndex++;
      }
      
      // Offset cho giờ tiếp theo (tạo pattern xoay vòng)
      timeIndex += 2; // Số lẻ để tạo pattern không lặp lại
    }
    
    return showtimes;
  }

  /// ========================================
  /// HÀ NỘI - 4 RẠP (17 phòng × 6 suất = 102 templates)
  /// ========================================
  
  /// 1️⃣ CGV Vincom Bà Triệu - Hà Nội (5 phòng: 3 Standard + 1 VIP + 1 IMAX)
  static List<Map<String, dynamic>> get cgvVincomBaTrieuShowtimes {
    return generateTheaterShowtimes(
      theaterExternalId: 'cgv-vincom-ba-trieu-hn',
      movieIds: [
        'tron-ares',              // Phòng 1 (Standard)
        'tu-chien-tren-khong',    // Phòng 2 (Standard)
        'cuc-vang-cua-ngoai',     // Phòng 3 (Standard)
        'tee-yod-3',              // Phòng 4 (VIP)
        'nha-ma-xo',              // Phòng 5 (IMAX)
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 1,
    );
  }

  /// 2️⃣ BHD Star Vincom Phạm Ngọc Thạch - Hà Nội (4 phòng)
  static List<Map<String, dynamic>> get bhdVincomPhamNgocThachShowtimes {
    return generateTheaterShowtimes(
      theaterExternalId: 'bhd-vincom-pham-ngoc-thach-hn',
      movieIds: [
        'tay-anh-giu-mot-vi-sao',
        'van-may',
        'to-quoc-trong-tim',
        'nha-ma-xo',
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 0,
    );
  }

  /// 3️⃣ Lotte Cinema West Lake - Hà Nội (4 phòng)
  static List<Map<String, dynamic>> get lotteWestLakeShowtimes {
    return generateTheaterShowtimes(
      theaterExternalId: 'lotte-west-lake-hn',
      movieIds: [
        'cuc-vang-cua-ngoai',
        'tee-yod-3',
        'tu-chien-tren-khong',
        'tron-ares',
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 0,
    );
  }

  /// 4️⃣ Galaxy Cinema Nguyễn Du - Hà Nội (4 phòng)
  static List<Map<String, dynamic>> get galaxyNguyenDuHanoiShowtimes {
    return generateTheaterShowtimes(
      theaterExternalId: 'galaxy-nguyen-du-hn',
      movieIds: [
        'van-may',
        'to-quoc-trong-tim',
        'cuc-vang-cua-ngoai',
        'tay-anh-giu-mot-vi-sao',
      ],
      standardScreenCount: 3,
      vipScreenCount: 1,
      imaxScreenCount: 0,
    );
  }

  /// ✅ Tất cả showtimes Hà Nội (17 phòng × 6 suất = 102 templates)
  static List<Map<String, dynamic>> get allHanoiShowtimes => [
    ...cgvVincomBaTrieuShowtimes,
    ...bhdVincomPhamNgocThachShowtimes,
    ...lotteWestLakeShowtimes,
    ...galaxyNguyenDuHanoiShowtimes,
  ];
}
