// lib/services/seed/hardcoded_screens_data.dart

/// ✅ REFACTORED: Real cinema screen layouts
/// 
/// Quy tắc thực tế:
/// - Standard screen: 8 hàng × 10 ghế - 2 aisles (cột 5-6) = 64 ghế
/// - VIP screen: 6 hàng × 8 ghế - 2 aisles (cột 4-5) = 36 ghế
/// - IMAX screen: 10 hàng × 12 ghế - 2 aisles (cột 6-7) = 100 ghế
/// - Lối đi: KHÔNG có ghế (để khách di chuyển)
/// - 2 hàng cuối: VIP seats (cho Standard & IMAX)
class HardcodedScreensData {
  
  /// ============================================
  /// STANDARD SCREEN: 8 hàng × 10 cột = 64 ghế
  /// ============================================
  /// Layout:
  ///     1  2  3  4 [  ] [  ]  7  8  9  10
  /// A  [□][□][□][□][  ][  ][□][□][□][□]
  /// B  [□][□][□][□][  ][  ][□][□][□][□]
  /// C  [□][□][□][□][  ][  ][□][□][□][□]
  /// D  [□][□][□][□][  ][  ][□][□][□][□]
  /// E  [□][□][□][□][  ][  ][□][□][□][□]
  /// F  [□][□][□][□][  ][  ][□][□][□][□]
  /// G  [◈][◈][◈][◈][  ][  ][◈][◈][◈][◈] ← VIP
  /// H  [◈][◈][◈][◈][  ][  ][◈][◈][◈][◈] ← VIP
  static List<Map<String, dynamic>> generateStandardSeats() {
    final seats = <Map<String, dynamic>>[];
    const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    const cols = 10;
    
    for (int r = 0; r < rows.length; r++) {
      final row = rows[r];
      for (int col = 1; col <= cols; col++) {
        // ❌ Skip aisles (cột 5-6 là lối đi)
        if (col == 5 || col == 6) continue;
        
        // ✅ 2 hàng cuối (G, H) là VIP
        final isVip = (r >= 6); // G=6, H=7
        
        seats.add({
          'id': '$row$col',
          'type': isVip ? 'vip' : 'standard',
          'isAvailable': true,
        });
      }
    }
    return seats;
  }

  /// ============================================
  /// VIP SCREEN: 6 hàng × 8 cột = 36 ghế (ALL VIP)
  /// ============================================
  /// Layout:
  ///     1  2  3 [  ] [  ]  6  7  8
  /// A  [◈][◈][◈][  ][  ][◈][◈][◈]
  /// B  [◈][◈][◈][  ][  ][◈][◈][◈]
  /// C  [◈][◈][◈][  ][  ][◈][◈][◈]
  /// D  [◈][◈][◈][  ][  ][◈][◈][◈]
  /// E  [◈][◈][◈][  ][  ][◈][◈][◈]
  /// F  [◈][◈][◈][  ][  ][◈][◈][◈]
  static List<Map<String, dynamic>> generateVIPSeats() {
    final seats = <Map<String, dynamic>>[];
    const rows = ['A', 'B', 'C', 'D', 'E', 'F'];
    const cols = 8;
    
    for (int r = 0; r < rows.length; r++) {
      final row = rows[r];
      for (int col = 1; col <= cols; col++) {
        // ❌ Skip aisles (cột 4-5 là lối đi cho VIP)
        if (col == 4 || col == 5) continue;
        
        seats.add({
          'id': '$row$col',
          'type': 'vip', // ✅ ALL VIP
          'isAvailable': true,
        });
      }
    }
    return seats;
  }

  /// ============================================
  /// IMAX SCREEN: 10 hàng × 12 cột = 100 ghế
  /// ============================================
  /// Layout:
  ///     1  2  3  4  5 [  ] [  ]  8  9 10 11 12
  /// A  [□][□][□][□][□][  ][  ][□][□][□][□][□]
  /// ...
  /// H  [◈][◈][◈][◈][◈][  ][  ][◈][◈][◈][◈][◈] ← VIP
  /// I  [◈][◈][◈][◈][◈][  ][  ][◈][◈][◈][◈][◈] ← VIP
  /// J  [◈][◈][◈][◈][◈][  ][  ][◈][◈][◈][◈][◈] ← VIP
  static List<Map<String, dynamic>> generateIMAXSeats() {
    final seats = <Map<String, dynamic>>[];
    const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    const cols = 12;
    
    for (int r = 0; r < rows.length; r++) {
      final row = rows[r];
      for (int col = 1; col <= cols; col++) {
        // ❌ Skip aisles (cột 6-7 là lối đi)
        if (col == 6 || col == 7) continue;
        
        // ✅ 3 hàng cuối (H, I, J) là VIP
        final isVip = (r >= 7); // H=7, I=8, J=9
        
        seats.add({
          'id': '$row$col',
          'type': isVip ? 'vip' : 'standard',
          'isAvailable': true,
        });
      }
    }
    return seats;
  }

  /// ============================================
  /// SCREEN CONFIGURATIONS PER THEATER
  /// ============================================
  
  /// Tạo 4-5 phòng chiếu cho 1 rạp
  /// - Rạp lớn (CGV/Lotte): 5 phòng (3 Standard + 1 VIP + 1 IMAX)
  /// - Rạp vừa: 4 phòng (3 Standard + 1 VIP)
  static List<Map<String, dynamic>> createScreensForTheater(
    String theaterExternalId, {
    bool hasIMAX = false,
  }) {
    final screens = <Map<String, dynamic>>[];
    
    // Standard screens (Phòng 1-3)
    for (int i = 1; i <= 3; i++) {
      screens.add({
        'externalId': '$theaterExternalId-screen-$i',
        'theaterExternalId': theaterExternalId,
        'name': 'Phòng $i',
        'type': 'standard',
        'totalSeats': 64, // 8×10 - 2 aisles = 64
        'rows': 8,
        'columns': 10,
        'seats': generateStandardSeats(),
      });
    }
    
    // VIP screen (Phòng 4)
    screens.add({
      'externalId': '$theaterExternalId-screen-4',
      'theaterExternalId': theaterExternalId,
      'name': 'Phòng 4 - VIP',
      'type': 'vip',
      'totalSeats': 36, // 6×8 - 2 aisles = 36
      'rows': 6,
      'columns': 8,
      'seats': generateVIPSeats(),
    });
    
    // IMAX screen (Phòng 5) - chỉ cho rạp lớn
    if (hasIMAX) {
      screens.add({
        'externalId': '$theaterExternalId-screen-5',
        'theaterExternalId': theaterExternalId,
        'name': 'Phòng 5 - IMAX',
        'type': 'imax',
        'totalSeats': 100, // 10×12 - 2 aisles = 100
        'rows': 10,
        'columns': 12,
        'seats': generateIMAXSeats(),
      });
    }
    
    return screens;
  }

  /// ============================================
  /// SCREENS BY THEATER (44 phòng tổng)
  /// ============================================
  
  /// Map screens theo theater externalId
  /// 
  /// Key: theater externalId
  /// Value: List của 4-5 screens
  static Map<String, List<Map<String, dynamic>>> get screensByTheater {
    return {
      // ================================================
      // HÀ NỘI - 4 rạp × 4-5 phòng = 17 phòng
      // ================================================
      
      // 1️⃣ CGV Vincom Bà Triệu (5 phòng - có IMAX)
      'cgv-vincom-ba-trieu-hn': createScreensForTheater(
        'cgv-vincom-ba-trieu-hn',
        hasIMAX: true,
      ),
      
      // 2️⃣ BHD Star Vincom Phạm Ngọc Thạch (4 phòng)
      'bhd-vincom-pham-ngoc-thach-hn': createScreensForTheater(
        'bhd-vincom-pham-ngoc-thach-hn',
      ),
      
      // 3️⃣ Lotte Cinema West Lake (4 phòng)
      'lotte-west-lake-hn': createScreensForTheater(
        'lotte-west-lake-hn',
      ),
      
      // 4️⃣ Galaxy Nguyễn Du Hà Nội (4 phòng)
      'galaxy-nguyen-du-hn': createScreensForTheater(
        'galaxy-nguyen-du-hn',
      ),
      
      // ================================================
      // TP. HỒ CHÍ MINH - 4 rạp × 4-5 phòng = 18 phòng
      // ================================================
      
      // 5️⃣ CGV Vincom Đồng Khởi (5 phòng - có IMAX)
      'cgv-vincom-dong-khoi-hcm': createScreensForTheater(
        'cgv-vincom-dong-khoi-hcm',
        hasIMAX: true,
      ),
      
      // 6️⃣ CGV Landmark 81 (5 phòng - có IMAX)
      'cgv-landmark-81-hcm': createScreensForTheater(
        'cgv-landmark-81-hcm',
        hasIMAX: true,
      ),
      
      // 7️⃣ Lotte Cinema Nam Sài Gòn (4 phòng)
      'lotte-nam-saigon-hcm': createScreensForTheater(
        'lotte-nam-saigon-hcm',
      ),
      
      // 8️⃣ Galaxy Nguyễn Du TP.HCM (4 phòng)
      'galaxy-nguyen-du-hcm': createScreensForTheater(
        'galaxy-nguyen-du-hcm',
      ),
      
      // ================================================
      // ĐÀ NẴNG - 3 rạp × 4 phòng = 12 phòng
      // ================================================
      
      // 9️⃣ CGV Vincom Đà Nẵng (4 phòng)
      'cgv-vincom-da-nang': createScreensForTheater(
        'cgv-vincom-da-nang',
      ),
      
      // 🔟 Lotte Cinema Vĩnh Trung Plaza (4 phòng)
      'lotte-vinh-trung-plaza-dn': createScreensForTheater(
        'lotte-vinh-trung-plaza-dn',
      ),
      
      // 1️⃣1️⃣ BHD Star Lotte Mart Đà Nẵng (4 phòng)
      'bhd-lotte-mart-da-nang': createScreensForTheater(
        'bhd-lotte-mart-da-nang',
      ),
    };
  }

  /// ✅ Lấy tất cả screens (47 phòng tổng)
  /// - 4 rạp Hà Nội: 17 phòng (1 IMAX)
  /// - 4 rạp TP.HCM: 18 phòng (3 IMAX)
  /// - 3 rạp Đà Nẵng: 12 phòng
  static List<Map<String, dynamic>> get allScreens {
    final screens = <Map<String, dynamic>>[];
    for (var theaterScreens in screensByTheater.values) {
      screens.addAll(theaterScreens);
    }
    return screens;
  }
  
  /// ✅ Get screens by theater external ID
  static List<Map<String, dynamic>> getScreensForTheater(String theaterExternalId) {
    return screensByTheater[theaterExternalId] ?? [];
  }
}
